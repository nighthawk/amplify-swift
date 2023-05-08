//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import Amplify
import Combine

final class PredictionsGettingStartedTestCase: XCTestCase {

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
    }

    func test_translatingText() async throws {
        // #-----# tranlate_text #-----#
        func translateText() async {
            do {
                let translatedText = try await Amplify.Predictions.convert(
                    .translateText(
                        "I like to eat spaghetti",
                        from: .english,
                        to: .spanish
                    )
                )
                print("Translated text: \(translatedText)")
            } catch let error as PredictionsError {
                print("Error translating text: \(error)")
            } catch {
                print("Unexpected error: \(error)")
            }
        }
        // #-----------#

        predictionsPlugin._translateText = .init { _, _ in
            .init(text: "Me gusta comer espaguetis", targetLanguage: .spanish)
        }
        await translateText()
    }

    var translateTextCancellable = Set<AnyCancellable>()
    func test_combine_translatingText() async throws {
        predictionsPlugin._translateText = .init { _, _ in
            .init(text: "Me gusta comer espaguetis", targetLanguage: .spanish)
        }
        // #-----# tranlate_text_combine #-----#
        Amplify.Publisher.create {
            try await Amplify.Predictions.convert(
                .translateText(
                    "I like to eat spaghetti!",
                    from: .english,
                    to: .spanish
                )
            )
        }
        .sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                print("Error translating text: \(error)")
            }
        }, receiveValue: { value in
            print("Translated text: \(value.text)")
        })
        // #-----------#
        .store(in: &translateTextCancellable)
    }
}
