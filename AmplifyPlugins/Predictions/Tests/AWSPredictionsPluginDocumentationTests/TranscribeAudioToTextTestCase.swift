//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest
import Amplify
import Combine

final class PredictionsTranscribeAudioToTextTestCase: XCTestCase {

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

    func test_speechToText() async throws {
        // #-----# speech_to_text #-----#
        func speechToText(url: URL) async throws {
            let options = Predictions.Convert.SpeechToText.Options(
                defaultNetworkPolicy: .auto,
                language: .usEnglish
            )

            let result = try await Amplify.Predictions.convert(
                .speechToText(url: url), options: options
            )

            let transcription = result.map(\.transcription)

            for try await transcriptionPart in transcription {
                print("transcription part: \(transcriptionPart)")
            }
        }
        // #-----------#

        predictionsPlugin._speechToText = .init { _, _ in
            let stream = AsyncThrowingStream(unfolding: {
                Bool.random()
                ? Predictions.Convert.SpeechToText.Result(transcription: "Hello, world!")
                : nil
            })
            return stream
        }
        try await speechToText(url: URL(string: "foo.bar")!)
    }
}
