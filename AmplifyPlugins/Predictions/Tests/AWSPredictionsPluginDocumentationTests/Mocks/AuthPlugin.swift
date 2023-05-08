//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify

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
