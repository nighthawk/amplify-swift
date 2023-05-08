//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import Amplify
@_spi(PredictionsConvertRequestKind) import Amplify

class AuthPlugin: AuthCategoryPlugin {
    var key: PluginKey

    init(key: PluginKey) {
        self.key = key
    }

    convenience init() {
        self.init(key: "mock_auth_plugin")
    }

    func configure(using configuration: Any?) throws {}

    func signUp(
        username: String,
        password: String?,
        options: AuthSignUpRequest.Options?
    ) async throws -> AuthSignUpResult {
        fatalError()
    }

    func confirmSignUp(
        for username: String,
        confirmationCode: String,
        options: AuthConfirmSignUpRequest.Options?
    ) async throws -> AuthSignUpResult {
        fatalError()
    }

    func resendSignUpCode(
        for username: String,
        options: AuthResendSignUpCodeRequest.Options?
    ) async throws -> AuthCodeDeliveryDetails {
        fatalError()
    }

    func signIn(
        username: String?,
        password: String?,
        options: AuthSignInRequest.Options?
    ) async throws -> AuthSignInResult {
        fatalError()
    }

    func signInWithWebUI(
        presentationAnchor: AuthUIPresentationAnchor?,
        options: AuthWebUISignInRequest.Options?
    ) async throws -> AuthSignInResult {
        fatalError()
    }

    func signInWithWebUI(
        for authProvider: AuthProvider,
        presentationAnchor: AuthUIPresentationAnchor?,
        options: AuthWebUISignInRequest.Options?
    ) async throws -> AuthSignInResult {
        fatalError()
    }

    func confirmSignIn(
        challengeResponse: String,
        options: AuthConfirmSignInRequest.Options?
    ) async throws -> AuthSignInResult {
        fatalError()
    }

    func signOut(
        options: AuthSignOutRequest.Options?
    ) async -> AuthSignOutResult { fatalError() }

    func deleteUser() async throws { fatalError() }

    func fetchAuthSession(
        options: AuthFetchSessionRequest.Options?
    ) async throws -> AuthSession { fatalError() }

    func resetPassword(
        for username: String,
        options: AuthResetPasswordRequest.Options?
    ) async throws -> AuthResetPasswordResult { fatalError() }

    func confirmResetPassword(
        for username: String,
        with newPassword: String,
        confirmationCode: String,
        options: AuthConfirmResetPasswordRequest.Options?
    ) async throws { fatalError() }

    func getCurrentUser() async throws -> AuthUser { fatalError() }

    func fetchUserAttributes(
        options: AuthFetchUserAttributesRequest.Options?
    ) async throws -> [AuthUserAttribute] { fatalError() }

    func update(
        userAttribute: AuthUserAttribute,
        options: AuthUpdateUserAttributeRequest.Options?
    ) async throws -> AuthUpdateAttributeResult { fatalError() }

    func update(
        userAttributes: [AuthUserAttribute],
        options: AuthUpdateUserAttributesRequest.Options?
    ) async throws -> [AuthUserAttributeKey: AuthUpdateAttributeResult] {
        fatalError()
    }

    func resendConfirmationCode(
        forUserAttributeKey userAttributeKey: AuthUserAttributeKey,
        options: AuthAttributeResendConfirmationCodeRequest.Options?
    ) async throws -> AuthCodeDeliveryDetails { fatalError() }

    func confirm(
        userAttribute: AuthUserAttributeKey,
        confirmationCode: String,
        options: AuthConfirmUserAttributeRequest.Options?
    ) async throws { fatalError() }

    func update(
        oldPassword: String,
        to newPassword: String,
        options: AuthChangePasswordRequest.Options?
    ) async throws { fatalError() }

    func fetchDevices(
        options: AuthFetchDevicesRequest.Options?
    ) async throws -> [AuthDevice] { fatalError() }

    func forgetDevice(
        _ device: AuthDevice?,
        options: AuthForgetDeviceRequest.Options?
    ) async throws { fatalError() }

    func rememberDevice(
        options: AuthRememberDeviceRequest.Options?
    ) async throws { fatalError() }

    func reset() async { fatalError() }
}

class PredictionsPlugin: PredictionsCategoryPlugin {
    var key: PluginKey

    init(key: PluginKey) {
        self.key = key
    }

    convenience init() {
        self.init(key: "mock_predictions_plugin")
    }

    func configure(using configuration: Any?) throws {}

    struct Convert<Input, Options, Output> {
        let run: (Input, Options?) -> Output
    }

    var _translateText: Convert<
        (String, Optional<Predictions.Language>, Optional<Predictions.Language>),
        Predictions.Convert.TranslateText.Options,
        Predictions.Convert.TranslateText.Result
    >?

    func identify<Output>(
        _ request: Predictions.Identify.Request<Output>,
        in image: URL,
        options: Predictions.Identify.Options?
    ) async throws -> Output {
        fatalError()
    }

    func convert<Input, Options, Output>(
        _ request: Predictions.Convert.Request<Input, Options, Output>,
        options: Options?
    ) async throws -> Output {
        switch request.kind {
        case .speechToText:
            fatalError()
        case .textToSpeech:
            fatalError()
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

    func interpret(
        text: String,
        options: Predictions.Interpret.Options?
    ) async throws -> Predictions.Interpret.Result {
        fatalError()
    }

    func reset() async {
        fatalError()
    }
}

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
}
