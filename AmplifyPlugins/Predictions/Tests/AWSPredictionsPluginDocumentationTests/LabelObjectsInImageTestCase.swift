//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import Amplify
import Combine

final class LabelObjectsInImageTestCase: XCTestCase {
    let authPlugin = AuthPlugin()
    let predictionsPlugin = PredictionsPlugin()

    func test_configure() {
        do {
            try Amplify.add(plugin: AuthPlugin())
            try Amplify.add(plugin: PredictionsPlugin())
            try Amplify.configure()
            print("Amplify configured with Auth and Predictions plugins")
        } catch {
            print("Failed to initialize Amplify with \(error)")
        }
    }

    override func setUp() {
        do {
            try Amplify.add(plugin: authPlugin)
            try Amplify.add(plugin: predictionsPlugin)
            let authConfiguration = AuthCategoryConfiguration(plugins: [:])
            let predictionsConfiguration = PredictionsCategoryConfiguration(plugins: [:])
            let configuration = AmplifyConfiguration(auth: authConfiguration, predictions: predictionsConfiguration)
            try Amplify.configure(configuration)
            print("Amplify configured with Auth and Predictions plugins")
        } catch {
            print("Failed to initialize Amplify with \(error)")
        }

        predictionsPlugin._detectLabels = .init { _, _ in
            .init(labels: [])
        }
    }

    func test_detectLabels() async throws {
        // #-----# detect_labels #-----#
        func detectLabels(_ image: URL) async throws -> Predictions.Identify.Labels.Result {
            do {
                let result = try await Amplify.Predictions.identify(.labels(type: .labels), in: image)
                print("Identified labels: \(result.labels)")
                return result
            }  catch let error as PredictionsError {
                print("Error identifying labels: \(error)")
                throw error
            } catch {
                print("Unexpected error: \(error)")
                throw error
            }
        }

        // To identify labels with unsafe content
        func detectAllLabels(_ image: URL) async throws -> Predictions.Identify.Labels.Result {
            do {
                let result = try await Amplify.Predictions.identify(.labels(type: .all), in: image)
                print("Identified labels: \(result.labels)")
                return result
            }  catch let error as PredictionsError {
                print("Error identifying labels: \(error)")
                throw error
            } catch {
                print("Unexpected error: \(error)")
                throw error
            }
        }
        // #-----------#

        _ = try await detectLabels(URL(string: "foo.bar")!)
        _ = try await detectAllLabels(URL(string: "foo.bar")!)
    }

    func test_combine_detectLabels() async throws {
        // #-----# detect_labels_combine #-----#
        func detectLabels(_ image: URL) -> AnyCancellable {
            Amplify.Publisher.create {
                try await Amplify.Predictions.identify(.labels(type: .labels), in: image)
            }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error identifying labels: \(error)")
                }
            }, receiveValue: { value in
                print("Identified labels: \(value.labels)")
            })
        }

        // To identify labels with unsafe content
        func detectAllLabels(_ image: URL) -> AnyCancellable {
            Amplify.Publisher.create {
                try await Amplify.Predictions.identify(.labels(type: .all), in: image)
            }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error identifying labels: \(error)")
                }
            }, receiveValue: { value in
                print("Identified labels: \(value.labels)")
            })
        }
        // #-----------#

        _ = detectLabels(URL(string: "foo.bar")!)
        _ = detectAllLabels(URL(string: "foo.bar")!)
    }
}
