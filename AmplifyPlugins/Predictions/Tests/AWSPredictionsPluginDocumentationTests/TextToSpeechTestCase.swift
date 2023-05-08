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

final class PredictionsTextToSpeechTestCase: PredictionsDocumentationBaseTestCase {
    var player: AVAudioPlayer?
    var textToSpeechSink: AnyCancellable?

    func test_textToSpeech() async throws {
        // #-----# text_to_speech #-----#
        func textToSpeech() async throws {
            let result = try await Amplify.Predictions.convert(
                .textToSpeech("Hello, world!"),
                options: .init(voice: .englishFemaleIvy)
            )
            print("TextToSpeech result: \(result)")
            player = try? AVAudioPlayer(data: result.audioData)
            player?.play()
        }
        // #-----------#
        predictionsPlugin._textToSpeech = .init { _, _ in
            .init(audioData: .init())
        }
        try await textToSpeech()
    }

    func test_combine_textToSpeech() async throws {
        // #-----# text_to_speech_combine #-----#
        func textToSpeech() {
          textToSpeechSink = Amplify.Publisher.create {
             try await Amplify.Predictions.convert(
                .textToSpeech("Hello, world!"),
                options: .init(voice: .englishFemaleIvy)
            )
          }
          .sink(receiveCompletion: { completion in
              if case let .failure(error) = completion {
                  print("Error converting text to speech: \(error)")
              }
          }, receiveValue: { result in
              print("TextToSpeech result: \(result)")
              self.player = try? AVAudioPlayer(data: result.audioData)
              self.player?.play()
          })
        }
        // #-----------#
        predictionsPlugin._textToSpeech = .init { _, _ in
            .init(audioData: .init())
        }
        textToSpeech()
    }
}

