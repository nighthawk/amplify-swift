//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import Amplify
import AWSPredictionsPlugin
import AWSRekognition

final class PredictionsEscapeHatchTestCase: XCTestCase {
    let authPlugin = AuthPlugin()
    let predictionsPlugin = PredictionsPlugin(key: "awsPredictionsPlugin")

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

    func test_escapeHatchRekognition() async throws {
        // #-----# escape_hatch_rekognition #-----#
        guard let predictionsPlugin = try Amplify.Predictions.getPlugin(for: "awsPredictionsPlugin") as? AWSPredictionsPlugin else {
            print("Unable to cast to AWSPredictionsPlugin")
            return
        }

        let rekognitionClient = predictionsPlugin.getEscapeHatch(key: .rekognition)
        let request = CreateCollectionInput()
        let output = try await rekognitionClient.createCollection(input: request)
        // #-----------#
        _ = output
    }

    func test_escapeHatchOthers() async throws {
        guard let predictionsPlugin = try Amplify.Predictions.getPlugin(for: "awsPredictionsPlugin") as? AWSPredictionsPlugin else {
            print("Unable to cast to AWSPredictionsPlugin")
            return
        }
        // #-----# escape_hatch_others #-----#
        let translateClient = predictionsPlugin.getEscapeHatch(key: .translate)
        let pollyClient = predictionsPlugin.getEscapeHatch(key: .polly)
        let comprehendClient = predictionsPlugin.getEscapeHatch(key: .comprehend)
        let textractClient = predictionsPlugin.getEscapeHatch(key: .textract)
        // #-----------#
        _ = translateClient; _ = pollyClient; _ = comprehendClient; _ = textractClient
    }
}
