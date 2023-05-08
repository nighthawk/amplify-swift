//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify
@_spi(PredictionsConvertRequestKind) import Amplify
@_spi(PredictionsIdentifyRequestKind) import Amplify

class PredictionsPlugin: PredictionsCategoryPlugin {
    var key: PluginKey

    init(key: PluginKey) {
        self.key = key
    }

    convenience init() {
        self.init(key: "mock_predictions_plugin")
    }

    func configure(using configuration: Any?) throws {}

    // MARK: Identify
    struct Identify<Output> {
        let run: (URL, Predictions.Identify.Options?) -> Output
    }

    var _detectCelebrities: Identify<Predictions.Identify.Celebrities.Result>?
    var _detectEntities: Identify<Predictions.Identify.Entities.Result>?
    var _detectEntitiesCollection: Identify<Predictions.Identify.EntityMatches.Result>?
    var _detectLabels: Identify<Predictions.Identify.Labels.Result>?
    var _detectTextInDocument: Identify<Predictions.Identify.DocumentText.Result>?
    var _detectText: Identify<Predictions.Identify.Text.Result>?

    func identify<Output>(
        _ request: Predictions.Identify.Request<Output>,
        in image: URL,
        options: Predictions.Identify.Options?
    ) async throws -> Output {
        switch request.kind {
        case let .detectText(lift):
            if let implementation = _detectText {
                return lift.outputSpecificToGeneric(implementation.run(image, options))
            } else {
                fatalError()
            }
        case let .detectTextInDocument(_, lift):
            if let implementation = _detectTextInDocument {
                return lift.outputSpecificToGeneric(implementation.run(image, options))
            } else {
                fatalError()
            }
        case let .detectEntitiesCollection(_, lift):
            if let implementation = _detectEntitiesCollection {
                return lift.outputSpecificToGeneric(implementation.run(image, options))
            } else {
                fatalError()
            }
        case .detectEntities(let lift):
            if let implementation = _detectEntities {
                return lift.outputSpecificToGeneric(implementation.run(image, options))
            } else {
                fatalError()
            }
        case let .detectCelebrities(lift):
            if let implementation = _detectCelebrities {
                return lift.outputSpecificToGeneric(implementation.run(image, options))
            } else {
                fatalError()
            }
        case let .detectLabels(_, lift):
            if let implementation = _detectLabels {
                return lift.outputSpecificToGeneric(implementation.run(image, options))
            } else {
                fatalError()
            }
        }
    }

    // MARK: Convert
    struct Convert<Input, Options, Output> {
        let run: (Input, Options?) -> Output
    }

    var _translateText: Convert<
        (String, Optional<Predictions.Language>, Optional<Predictions.Language>),
        Predictions.Convert.TranslateText.Options,
        Predictions.Convert.TranslateText.Result
    >?

    var _textToSpeech: Convert<
        String,
        Predictions.Convert.TextToSpeech.Options,
        Predictions.Convert.TextToSpeech.Result
    >?

    var _speechToText: Convert<
        URL,
        Predictions.Convert.SpeechToText.Options,
        AsyncThrowingStream<Predictions.Convert.SpeechToText.Result, Error>
    >?

    func convert<Input, Options, Output>(
        _ request: Predictions.Convert.Request<Input, Options, Output>,
        options: Options?
    ) async throws -> Output {
        switch request.kind {
        case .speechToText(let lift):
            if let implementation = _speechToText {
                let input = lift.inputGenericToSpecific(request.input)
                let options = lift.optionsGenericToSpecific(options)
                return lift.outputSpecificToGeneric(implementation.run(input, options))
            } else {
                fatalError("Missing implementation.")
            }
        case .textToSpeech(let lift):
            if let implementation = _textToSpeech {
                let input = lift.inputGenericToSpecific(request.input)
                let options = lift.optionsGenericToSpecific(options)
                return lift.outputSpecificToGeneric(implementation.run(input, options))
            } else {
                fatalError("Missing implementation.")
            }
        case .textToTranslate(let lift):
            if let implementation = _translateText {
                let input = lift.inputGenericToSpecific(request.input)
                let options = lift.optionsGenericToSpecific(options)
                return lift.outputSpecificToGeneric(implementation.run(input, options))
            } else {
                fatalError("Missing implementation.")
            }
        }
    }

    // MARK: Interpret
    var _interpret: ((String, Predictions.Interpret.Options?) -> Predictions.Interpret.Result)?

    func interpret(
        text: String,
        options: Predictions.Interpret.Options?
    ) async throws -> Predictions.Interpret.Result {
        if let implementation = _interpret {
            return implementation(text, options)
        } else {
            fatalError("Missing implementation.")
        }
    }

    func reset() async {}
}
