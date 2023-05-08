//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import Amplify
import Combine

final class PredictionsIdentifyEntitiesFromImagesTestCase: XCTestCase {
    let authPlugin = AuthPlugin()
    let predictionsPlugin = PredictionsPlugin()

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

        predictionsPlugin._detectEntities = .init { _, _ in
            .init(entities: [])
        }

        predictionsPlugin._detectCelebrities = .init { _, _ in
            .init(celebrities: [])
        }
    }

    func test_detectEntities() async throws {
        // #-----# detect_entities #-----#
        func detectEntities(_ image: URL) async throws -> [Predictions.Entity] {
            do {
                let result = try await Amplify.Predictions.identify(.entities, in: image)
                print("Identified entities: \(result.entities)")
                return result.entities
            } catch let error as PredictionsError {
                print("Error identifying entities: \(error)")
                throw error
            } catch {
                print("Unexpected error: \(error)")
                throw error
            }
        }
        // #-----------#

        _ = try await detectEntities(URL(string: "foo.bar")!)
    }

    func test_combine_detectEntities() async throws {
        // #-----# detect_entities_combine #-----#
        func detectEntities(_ image: URL) -> AnyCancellable {
            Amplify.Publisher.create {
                try await Amplify.Predictions.identify(.entities, in: image)
            }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error identifying entities: \(error)")
                }
            }, receiveValue: { value in
                print("Identified entities: \(value.entities)")
            })
        }
        // #-----------#

        _ = detectEntities(URL(string: "foo.bar")!)
    }

    func test_detectCelebrites() async throws {
        // #-----# detect_celebrities #-----#
        func detectCelebrities(_ image: URL) async throws -> [Predictions.Celebrity] {
            do {
                let result = try await Amplify.Predictions.identify(.celebrities, in: image)
                let celebrities = result.celebrities
                let celebritiesNames = celebrities.map(\.metadata.name)
                print("Identified celebrities with names: \(celebritiesNames)")
                return celebrities
            } catch let error as PredictionsError {
                print("Error identifying celebrities: \(error)")
                throw error
            } catch {
                print("Unexpected error: \(error)")
                throw error
            }
        }
        // #-----------#

        _ = try await detectCelebrities(URL(string: "foo.bar")!)
    }

    func test_combine_detectCelebrites() async throws {
        // #-----# detect_celebrities_combine #-----#
        func detectCelebrities(_ image: URL) -> AnyCancellable {
            Amplify.Publisher.create {
                try await Amplify.Predictions.identify(.celebrities, in: image)
            }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error identifying celebrities: \(error)")
                }
            }, receiveValue: { value in
                print("Identified celebrities with names: \(value.celebrities.map(\.metadata.name))")
            })
        }
        // #-----------#

        _ = detectCelebrities(URL(string: "foo.bar")!)
    }
}
