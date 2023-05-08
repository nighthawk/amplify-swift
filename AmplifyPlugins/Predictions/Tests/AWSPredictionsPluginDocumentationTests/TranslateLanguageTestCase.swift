//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import Amplify
import Combine
import AVFoundation
import AWSPredictionsPlugin

final class PredictionsTranslateLanguageTestCase: XCTestCase {
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
    }

    func test_translateText() async throws {
        // #-----# tranlate_text #-----#
        func translateText(text: String) async throws -> String {
          do {
            let result = try await Amplify.Predictions.convert(
                .translateText(text, from: .english, to: .italian)
            )
            print("Translated text: \(result.text)")
            return result.text
          } catch let error as PredictionsError {
              print("Error translating text: \(error)")
              throw error
          } catch {
              print("Unexpected error: \(error)")
              throw error
          }
        }
        // #-----------#

        predictionsPlugin._translateText = .init { _, _ in
            .init(text: "Me gusta comer espaguetis", targetLanguage: .spanish)
        }
        _ = try await translateText(text: "Hello, world!")
    }

    var translateTextCancellable = Set<AnyCancellable>()
    func test_combine_translateText() async throws {
        // #-----# tranlate_text_combine #-----#
        func translateText(text: String) -> AnyCancellable {
            Amplify.Publisher.create {
                try await Amplify.Predictions.convert(
                  .translateText(text, from: .english, to: .italian)
                )
            }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error translating text: \(error)")
                }
            }, receiveValue: { value in
                print("Translated text: \(value.text)")
            })
        }
        // #-----------#

        predictionsPlugin._translateText = .init { _, _ in
            .init(text: "Me gusta comer espaguetis", targetLanguage: .italian)
        }
        translateText(text: "Hello, world!")
            .store(in: &translateTextCancellable)
    }
}
