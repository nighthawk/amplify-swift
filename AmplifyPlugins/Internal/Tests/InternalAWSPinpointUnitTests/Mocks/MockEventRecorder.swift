//
//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSPinpoint
@_spi(InternalAWSPinpoint) @testable import InternalAWSPinpoint

actor MockEventRecorder: AnalyticsEventRecording {
    nonisolated var pinpointClient: PinpointClientProtocol {
        MockPinpointClient()
    }

    var saveCount = 0
    var lastSavedEvent: PinpointEvent?
    var updateCount = 0

    func save(_ event: PinpointEvent) throws {
        saveCount += 1
        lastSavedEvent = event
    }

    func updateAttributesOfEvents(ofType: String,
                                  withSessionId: PinpointSession.SessionId,
                                  setAttributes: [String: String]) throws {
        updateCount += 1
    }

    var submitCount = 0
    func submitAllEvents() async throws -> [PinpointEvent] {
        submitCount += 1
        return []
    }
}
