//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoAuthPlugin
import AWSPinpoint
import ClientRuntime
import enum AwsCommonRuntimeKit.CommonRunTimeError
import Foundation

/// AnalyticsEventRecording saves and submits pinpoint events
protocol AnalyticsEventRecording: Actor {
    nonisolated var pinpointClient: PinpointClientProtocol { get }

    /// Saves a pinpoint event to storage
    /// - Parameter event: A PinpointEvent
    func save(_ event: PinpointEvent) throws

    /// Updates attributes of the events with the provided session id
    /// - Parameters:
    ///   - ofType: event type
    ///   - withSessionId: session identifier
    ///   - setAttributes: event attributes
    func updateAttributesOfEvents(ofType: String,
                                  withSessionId: PinpointSession.SessionId,
                                  setAttributes: [String: String]) throws

    /// Submit all locally stored events
    /// - Returns: A collection of events submitted to Pinpoint
    func submitAllEvents() async throws -> [PinpointEvent]
}

/// An AnalyticsEventRecording implementation that stores and submits pinpoint events
actor EventRecorder: AnalyticsEventRecording {
    private let appId: String
    private let storage: AnalyticsEventStorage
    private var submittedEvents: [PinpointEvent] = []
    private var submissionTask: Task<[PinpointEvent], Error>?
    nonisolated let endpointClient: EndpointClientBehaviour
    nonisolated let pinpointClient: PinpointClientProtocol

    /// Initializer for Event Recorder
    /// - Parameters:
    ///   - appId: The Pinpoint App Id
    ///   - storage: A storage object that conforms to AnalyticsEventStorage
    ///   - pinpointClient: A Pinpoint client
    ///   - endpointClient: An EndpointClientBehaviour client
    init(appId: String,
         storage: AnalyticsEventStorage,
         pinpointClient: PinpointClientProtocol,
         endpointClient: EndpointClientBehaviour) throws {
        self.appId = appId
        self.storage = storage
        self.pinpointClient = pinpointClient
        self.endpointClient = endpointClient
        try self.storage.initializeStorage()
        try self.storage.deleteDirtyEvents()
        try self.storage.checkDiskSize(limit: Constants.pinpointClientByteLimitDefault)
    }

    /// Saves a pinpoint event to storage
    /// - Parameter event: A PinpointEvent
    func save(_ event: PinpointEvent) throws {
        log.verbose("saveEvent: \(event)")
        try storage.saveEvent(event)
        try storage.checkDiskSize(limit: Constants.pinpointClientByteLimitDefault)
    }

    func updateAttributesOfEvents(ofType eventType: String,
                                  withSessionId sessionId: PinpointSession.SessionId,
                                  setAttributes attributes: [String: String]) throws {
        try storage.updateEvents(ofType: eventType,
                                      withSessionId: sessionId,
                                      setAttributes: attributes)
    }

    /// Submit all locally stored events in batches. If a previous submission is in progress, it waits until it's completed before proceeding.
    /// When the submission for an event is accepted, the event is removed from local storage
    /// When the submission for an event is rejected, the event retry count is incremented in the local storage. Events that exceed the maximum retry count (3) are purged.
    /// - Returns: A collection of events submitted to Pinpoint
    func submitAllEvents() async throws -> [PinpointEvent] {
        let task = Task { [submissionTask] in
            // Wait for the previous submission to complete, regardless of its result
            _ = try? await submissionTask?.value
            submittedEvents = []
            let eventsBatch = try getBatchRecords()
            if eventsBatch.count > 0 {
                let endpointProfile = await endpointClient.currentEndpointProfile()
                try await processBatch(eventsBatch, endpointProfile: endpointProfile)
            } else {
                log.verbose("No events to submit")
            }
            return submittedEvents
        }
        submissionTask = task
        return try await task.value
    }

    private func getBatchRecords() throws -> [PinpointEvent] {
        return try storage.getEventsWith(limit: Constants.maxEventsSubmittedPerBatch)
    }

    private func processBatch(_ eventBatch: [PinpointEvent], endpointProfile: PinpointEndpointProfile) async throws {
        log.verbose("Submitting batch with \(eventBatch.count) events ")
        do {
            try await submit(pinpointEvents: eventBatch, endpointProfile: endpointProfile)
        } catch {
            // If the submit operation fails, attempt to update the database regardless and rethrow the error
            try storage.removeFailedEvents()
            throw error
        }
        try storage.removeFailedEvents()
        let nextEventsBatch = try getBatchRecords()
        if nextEventsBatch.count > 0 {
            try await processBatch(nextEventsBatch, endpointProfile: endpointProfile)
        }
    }

    private func submit(pinpointEvents: [PinpointEvent],
                        endpointProfile: PinpointEndpointProfile) async throws {
        var clientEvents = [String: PinpointClientTypes.Event]()
        var pinpointEventsById = [String: PinpointEvent]()
        for event in pinpointEvents {
            clientEvents[event.id] = event.clientTypeEvent
            pinpointEventsById[event.id] = event
        }

        let publicEndpoint = endpointClient.convertToPublicEndpoint(endpointProfile)
        let eventsBatch = PinpointClientTypes.EventsBatch(endpoint: publicEndpoint,
                                                          events: clientEvents)
        let batchItem = [endpointProfile.endpointId: eventsBatch]
        let putEventsInput = PutEventsInput(applicationId: appId,
                                            eventsRequest: .init(batchItem: batchItem))

        await identifySource(for: pinpointEvents)
        do {
            log.verbose("PutEventsInput: \(putEventsInput)")
            let response = try await pinpointClient.putEvents(input: putEventsInput)
            log.verbose("PutEventsOutput received: \(response)")
            guard let results = response.eventsResponse?.results else {
                let errorMessage = "Unexpected response from server when attempting to submit events."
                log.error(errorMessage)
                throw AnalyticsError.unknown(errorMessage)
            }

            let endpointResponseMap = results.compactMap { $0.value.endpointItemResponse }
            for endpointResponse in endpointResponseMap {
                if HttpStatusCode.accepted.rawValue == endpointResponse.statusCode {
                    log.verbose("EndpointProfile updated successfully.")
                } else {
                    log.error("Unable to update EndpointProfile. Error: \(endpointResponse.message ?? "Unknown")")
                }
            }

            let eventsResponseMap = results.compactMap { $0.value.eventsItemResponse }
            for (eventId, eventResponse) in eventsResponseMap.flatMap({ $0 }) {
                guard let event = pinpointEventsById[eventId] else { continue }
                let responseMessage = eventResponse.message ?? "Unknown"
                if HttpStatusCode.accepted.rawValue == eventResponse.statusCode,
                   Constants.acceptedResponseMessage == responseMessage {
                    // On successful submission, add the event to the list of submitted events and delete it from the local storage
                    log.verbose("Successful submit for event with id \(eventId)")
                    submittedEvents.append(event)
                    deleteEvent(eventId: eventId)
                } else if HttpStatusCode.badRequest.rawValue == eventResponse.statusCode {
                    // On bad request responses, mark the event as dirty
                    log.error("Server rejected submission of event. Event with id \(eventId) will be discarded. Error: \(responseMessage)")
                    setDirtyEvent(eventId: eventId)
                } else {
                    // On other failures, increment the event retry counter
                    incrementEventRetry(eventId: eventId)
                    let retryMessage: String
                    if event.retryCount < Constants.maxNumberOfRetries {
                        retryMessage = "Event will be retried"
                    } else {
                        retryMessage = "Event will be discarded because it exceeded its max retry attempts"
                    }
                    log.verbose("Submit attempt #\(event.retryCount + 1) for event with id \(eventId) failed.")
                    log.error("Unable to successfully deliver event with id \(eventId) to the server. \(retryMessage). Error: \(responseMessage)")
                }
            }

            // If no event was submitted successfuly, consider the operation a failure
            // and throw an error so that consumers can be notified
            if submittedEvents.isEmpty, !pinpointEvents.isEmpty {
                let errorMessage = "Unable to submit \(pinpointEvents.count) events"
                log.error(errorMessage)
                throw AnalyticsError.unknown(errorMessage)
            }
        } catch let analyticsError as AnalyticsError {
            // This is a known error explicitly thrown inside the do/catch block, so just rethrow it so it can be handled by the consumer
            throw analyticsError
        } catch let authError as AuthError {
            // This means all events were rejected due to an Auth error
            log.error("Unable to submit \(pinpointEvents.count) events. Error: \(authError.errorDescription). \(authError.recoverySuggestion)")
            switch authError {
            case .signedOut,
                 .sessionExpired:
                // Session Expired and Signed Out errors should be retried indefinitely, so we won't update the database
                log.verbose("Events will be retried")
            case .service:
                if case .invalidAccountTypeException = authError.underlyingError as? AWSCognitoAuthError {
                    // Unsupported Guest Access errors should be retried indefinitely, so we won't update the database
                    log.verbose("Events will be retried")
                } else {
                    fallthrough
                }
            default:
                if let underlyingError = authError.underlyingError {
                    // Handle the underlying error accordingly
                    handleError(underlyingError, for: pinpointEvents)
                } else {
                    // Otherwise just mark all events as dirty
                    log.verbose("Events will be discarded")
                    markEventsAsDirty(pinpointEvents)
                }
            }

            // Rethrow the original error so it can be handled by the consumer
            throw authError
        } catch {
            // This means all events were rejected
            log.error("Unable to submit \(pinpointEvents.count) events. Error: \(errorDescription(error)).")
            handleError(error, for: pinpointEvents)

            // Rethrow the original error so it can be handled by the consumer
            throw error
        }
    }
    
    private func handleError(_ error: Error, for pinpointEvents: [PinpointEvent]) {
        if isConnectivityError(error) {
            // Connectivity errors should be retried indefinitely, so we won't update the database
            log.verbose("Events will be retried")
            return
        }

        if isErrorRetryable(error) {
            // For retryable errors, increment the events retry count
            log.verbose("Events' retry count will be increased")
            incrementRetryCounter(for: pinpointEvents)
        } else {
            // For remaining errors, mark events as dirty
            log.verbose("Events will be discarded")
            markEventsAsDirty(pinpointEvents)
        }
    }

    private func isErrorRetryable(_ error: Error) -> Bool {
        guard case let modeledError as ModeledError = error else {
            return false
        }
        return type(of: modeledError).isRetryable
    }
    
    private func errorDescription(_ error: Error) -> String {
        if isConnectivityError(error) {
            return AWSPinpointErrorConstants.deviceOffline.errorDescription
        }
        switch error {
        case let error as ModeledErrorDescribable:
            return error.errorDescription
        case let error as CommonRunTimeError:
            switch error {
            case .crtError(let crtError):
                return crtError.message
            }
        default:
            return error.localizedDescription
        }
    }
    
    private func isConnectivityError(_ error: Error) -> Bool {
        switch error {
        case let error as CommonRunTimeError:
            return error.isConnectivityError
        case let error as NSError:
            let networkErrorCodes = [
                NSURLErrorCannotFindHost,
                NSURLErrorCannotConnectToHost,
                NSURLErrorNetworkConnectionLost,
                NSURLErrorDNSLookupFailed,
                NSURLErrorNotConnectedToInternet
            ]
            return networkErrorCodes.contains(where: { $0 == error.code })
        default:
            return false
        }
    }
    
    private func deleteEvent(eventId: String) {
        retry(onErrorMessage: "Unable to delete event with id \(eventId).") {
            try storage.deleteEvent(eventId: eventId)
        }
    }

    private func setDirtyEvent(eventId: String) {
        retry(onErrorMessage: "Unable to mark event with id \(eventId) as dirty.") {
            try storage.setDirtyEvent(eventId: eventId)
        }
    }
    
    private func markEventsAsDirty(_ events: [PinpointEvent]) {
        events.forEach { setDirtyEvent(eventId: $0.id) }
    }


    private func incrementEventRetry(eventId: String) {
        retry(onErrorMessage: "Unable to update retry count for event with id \(eventId).") {
            try storage.incrementEventRetry(eventId: eventId)
        }
    }
    
    private func incrementRetryCounter(for events: [PinpointEvent]) {
        events.forEach { incrementEventRetry(eventId: $0.id) }
    }

    private func retry(times: Int = Constants.defaultNumberOfRetriesForStorageOperations,
                       onErrorMessage: String,
                       _ closure: () throws -> Void) {
        do {
            try closure()
        } catch {
            if times > 0 {
                log.verbose("\(onErrorMessage). Retrying.")
                retry(times: times - 1, onErrorMessage: onErrorMessage, closure)
            } else {
                log.error(onErrorMessage)
                log.error(error: error)
            }
        }
    }

    private func identifySource(for pinpointEvents: [PinpointEvent]) async {
        let numberOfPushNotificationsEvents = pinpointEvents.numberOfPushNotificationsEvents()
        if numberOfPushNotificationsEvents > 0 {
            await PinpointRequestsRegistry.shared.registerSource(.pushNotifications, for: .recordEvent)
        }
        if pinpointEvents.count > numberOfPushNotificationsEvents {
            await PinpointRequestsRegistry.shared.registerSource(.analytics, for: .recordEvent)
        }
    }
}

extension EventRecorder: DefaultLogger {
    public static var log: Logger {
        Amplify.Logging.logger(forCategory: CategoryType.analytics.displayName, forNamespace: String(describing: self))
    }
    nonisolated public var log: Logger {
        Self.log
    }
}

extension EventRecorder {
    private struct Constants {
        static let maxEventsSubmittedPerBatch = 100
        static let pinpointClientByteLimitDefault = 5 * 1024 * 1024 // 5MB
        static let pinpointClientBatchRecordByteLimitDefault = 512 * 1024 // 0.5MB
        static let pinpointClientBatchRecordByteLimitMax = 4 * 1024 * 1024 // 4MB
        static let acceptedResponseMessage = "Accepted"
        static let defaultNumberOfRetriesForStorageOperations = 1
        static let maxNumberOfRetries = 3
    }
}

private extension Array where Element == PinpointEvent {
    func numberOfPushNotificationsEvents() -> Int {
        let pushNotificationsEvents = filter({ event in
            event.eventType.contains(".opened_notification")
            || event.eventType.contains(".received_foreground")
            || event.eventType.contains(".received_background")
        })
        return pushNotificationsEvents.count
    }
}
