//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import Amplify
import Combine

final class InterpretSentimentTestCase: XCTestCase {
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

        predictionsPlugin._interpret = { _, _ in
            .init(keyPhrases: [], sentiment: nil, entities: [], language: nil, syntax: [])
        }
    }

    func test_interpretSentiment() async throws {
        // #-----# interpret_sentiment #-----#
        func interpret(text: String) async throws -> Predictions.Interpret.Result {
            do {
                let result = try await Amplify.Predictions.interpret(text: text)
                print("Interpreted text: \(result)")
                return result
            } catch let error as PredictionsError {
                print("Error interpreting text: \(error)")
                throw error
            } catch {
                print("Unexpected error: \(error)")
                throw error
            }
        }
        // #-----------#

        _ = try await interpret(text: "Hello, world!")
    }

    func test_combine_interpretSentiment() async throws {
        // #-----# interpret_sentiment_combine #-----#
        func interpret(text: String) -> AnyCancellable {
            Amplify.Publisher.create {
                try await Amplify.Predictions.interpret(text: text)
            }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error interpreting text: \(error)")
                }
            }, receiveValue: { value in
                print("Interpreted text: \(value)")
            })
        }
        // #-----------#

        _ = interpret(text: "Hello, world!")
    }
}
