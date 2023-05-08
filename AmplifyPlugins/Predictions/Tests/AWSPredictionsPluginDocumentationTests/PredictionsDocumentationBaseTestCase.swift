//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//


import XCTest
@testable import Amplify

class PredictionsDocumentationBaseTestCase: XCTestCase {
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

    override func tearDown() async throws {
        await Amplify.reset()
    }
}
