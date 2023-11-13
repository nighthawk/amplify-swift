//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

import XCTest
@testable import Amplify
@testable import AWSCognitoAuthPlugin



class UserBehaviorChangePasswordTests: BasePluginTest {

    /// Test a successful changePassword call
    ///
    /// - Given: an auth plugin with mocked service. Mocked service calls should mock a successful response
    /// - When:
    ///    - I invoke changePassword with old password and new password
    /// - Then:
    ///    - I should get a successful result
    ///
    func testSuccessfulChangePassword() async throws {
        self.mockIdentityProvider = MockIdentityProvider(mockChangePasswordOutputResponse: { _ in
            return ChangePasswordOutputResponse()
        })
        try await plugin.update(oldPassword: "old password", to: "new password")
    }

    /// Test a changePassword call with InternalErrorException response from service
    ///
    /// - Given: an auth plugin with mocked service. Mocked service should mock a InternalErrorException response
    /// - When:
    ///    - I invoke changePassword with old password and new password
    /// - Then:
    ///    - I should get an .unknown error
    ///
    func testChangePasswordWithInternalErrorException() async throws {

        self.mockIdentityProvider = MockIdentityProvider(mockChangePasswordOutputResponse: { _ in
            throw InternalErrorException(name: nil, message: "internal error exception", httpURLResponse: .init())
        })
        do {
            try await plugin.update(oldPassword: "old password", to: "new password")
            XCTFail("Should return an error if the result from service is invalid")
        } catch {
            guard case AuthError.unknown = error else {
                XCTFail("Should produce an unknown error instead of \(error)")
                return
            }
        }
    }

    /// Test a changePassword call with InvalidParameterException response from service
    ///
    /// - Given: an auth plugin with mocked service. Mocked service should mock a
    ///   InvalidParameterException response
    ///
    /// - When:
    ///    - I invoke changePassword with old password and new password
    /// - Then:
    ///    - I should get a .service error with  .invalidParameter as underlyingError
    ///
    func testChangePasswordWithInvalidParameterException() async throws {

        self.mockIdentityProvider = MockIdentityProvider(mockChangePasswordOutputResponse: { _ in
            throw InvalidParameterException(name: nil, message: "invalid parameter exception", httpURLResponse: .init())
        })
        do {
            try await plugin.update(oldPassword: "old password", to: "new password")
            XCTFail("Should return an error if the result from service is invalid")
        } catch {
            guard case AuthError.service(_, _, let underlyingError) = error else {
                XCTFail("Should produce service error instead of \(error)")
                return
            }
            guard case .invalidParameter = (underlyingError as? AWSCognitoAuthError) else {
                XCTFail("Underlying error should be invalidParameter \(error)")
                return
            }
        }
    }

    /// Test a changePassword call with InvalidPasswordException response from service
    ///
    /// - Given: an auth plugin with mocked service. Mocked service should mock a
    ///   InvalidPasswordException response
    ///
    /// - When:
    ///    - I invoke changePassword with old password and new password
    /// - Then:
    ///    - I should get a .service error with  .invalidPassword as underlyingError
    ///
    func testChangePasswordWithInvalidPasswordException() async throws {

        self.mockIdentityProvider = MockIdentityProvider(mockChangePasswordOutputResponse: { _ in
            throw InvalidPasswordException(name: nil, message: "invalid password exception", httpURLResponse: .init())
        })
        do {
            try await plugin.update(oldPassword: "old password", to: "new password")
            XCTFail("Should return an error if the result from service is invalid")
        } catch {
            guard case AuthError.service(_, _, let underlyingError) = error else {
                XCTFail("Should produce service error instead of \(error)")
                return
            }
            guard case .invalidPassword = (underlyingError as? AWSCognitoAuthError) else {
                XCTFail("Underlying error should be invalidPassword \(error)")
                return
            }
        }
    }

    /// Test a changePassword call with LimitExceededException response from service
    ///
    /// - Given: an auth plugin with mocked service. Mocked service should mock a
    ///   LimitExceededException response
    ///
    /// - When:
    ///    - I invoke changePassword with old password and new password
    /// - Then:
    ///    - I should get a .limitExceeded error
    ///
    func testChangePasswordWithLimitExceededException() async throws {

        self.mockIdentityProvider = MockIdentityProvider(mockChangePasswordOutputResponse: { _ in
            throw LimitExceededException(
                name: nil,
                message: nil,
                httpURLResponse: .init()
            )
        })
        do {
            try await plugin.update(oldPassword: "old password", to: "new password")
            XCTFail("Should return an error if the result from service is invalid")
        } catch {
            guard case AuthError.service(_, _, let underlyingError) = error else {
                XCTFail("Should produce service error instead of \(error)")
                return
            }
            guard case .limitExceeded = (underlyingError as? AWSCognitoAuthError) else {
                XCTFail("Underlying error should be limitExceeded \(error)")
                return
            }
        }
    }

    /// Test a changePassword call with NotAuthorizedException response from service
    ///
    /// - Given: an auth plugin with mocked service. Mocked service should mock a
    ///   NotAuthorizedException response
    ///
    /// - When:
    ///    - I invoke changePassword with old password and new password
    /// - Then:
    ///    - I should get a .notAuthorized error
    ///
    func testChangePasswordWithNotAuthorizedException() async throws {

        self.mockIdentityProvider = MockIdentityProvider(mockChangePasswordOutputResponse: { _ in
            throw NotAuthorizedException(name: nil, message: "not authorized exception", httpURLResponse: .init())
        })
        do {
            try await plugin.update(oldPassword: "old password", to: "new password")
            XCTFail("Should return an error if the result from service is invalid")
        } catch {
            guard case AuthError.notAuthorized = error else {
                XCTFail("Should produce notAuthorized error instead of \(error)")
                return
            }
        }
    }

    /// Test a changePassword with PasswordResetRequiredException from service
    ///
    /// - Given: an auth plugin with mocked service. Mocked service should mock a
    ///   PasswordResetRequiredException response
    ///
    /// - When:
    ///    - I invoke changePassword with old password and new password
    /// - Then:
    ///    - I should get a .service error with .passwordResetRequired as underlyingError as underlying error
    ///
    func testChangePasswordWithPasswordResetRequiredException() async throws {

        self.mockIdentityProvider = MockIdentityProvider(mockChangePasswordOutputResponse: { _ in
            throw PasswordResetRequiredException(name: nil, message: "password reset required exception", httpURLResponse: .init())
        })
        do {
            try await plugin.update(oldPassword: "old password", to: "new password")
            XCTFail("Should return an error if the result from service is invalid")
        } catch {
            guard case AuthError.service(_, _, let underlyingError) = error else {
                XCTFail("Should produce service error instead of \(error)")
                return
            }
            guard case .passwordResetRequired = (underlyingError as? AWSCognitoAuthError) else {
                XCTFail("Underlying error should be passwordResetRequired \(error)")
                return
            }
        }
    }

    /// Test a changePassword call with ResourceNotFoundException response from service
    ///
    /// - Given: an auth plugin with mocked service. Mocked service should mock a
    ///   ResourceNotFoundException response
    ///
    /// - When:
    ///    - I invoke changePassword with old password and new password
    /// - Then:
    ///    - I should get a .service error with .resourceNotFound as underlyingError
    ///
    func testChangePasswordWithResourceNotFoundException() async throws {

        self.mockIdentityProvider = MockIdentityProvider(mockChangePasswordOutputResponse: { _ in
            throw ResourceNotFoundException(name: nil, message: "resource not found exception", httpURLResponse: .init())
        })
        do {
            try await plugin.update(oldPassword: "old password", to: "new password")
            XCTFail("Should return an error if the result from service is invalid")
        } catch {
            guard case AuthError.service(_, _, let underlyingError) = error else {
                XCTFail("Should produce service error instead of \(error)")
                return
            }
            guard case .resourceNotFound = (underlyingError as? AWSCognitoAuthError) else {
                XCTFail("Underlying error should be resourceNotFound \(error)")
                return
            }
        }
    }

    /// Test a changePassword call with TooManyRequestsException response from service
    ///
    /// - Given: an auth plugin with mocked service. Mocked service should mock a
    ///   TooManyRequestsException response
    ///
    /// - When:
    ///    - I invoke changePassword with old password and new password
    /// - Then:
    ///    - I should get a .service error with .requestLimitExceeded as underlyingError
    ///
    func testChangePasswordWithTooManyRequestsException() async throws {

        self.mockIdentityProvider = MockIdentityProvider(mockChangePasswordOutputResponse: { _ in
            throw TooManyRequestsException(name: nil, message: "too many requests exception", httpURLResponse: .init())
        })
        do {
            try await plugin.update(oldPassword: "old password", to: "new password")
            XCTFail("Should return an error if the result from service is invalid")
        } catch {
            guard case AuthError.service(_, _, let underlyingError) = error else {
                XCTFail("Should produce service error instead of \(error)")
                return
            }
            guard case .requestLimitExceeded = (underlyingError as? AWSCognitoAuthError) else {
                XCTFail("Underlying error should be requestLimitExceeded \(error)")
                return
            }
        }
    }

    /// Test a changePassword call with UserNotConfirmedException response from service
    ///
    /// - Given: an auth plugin with mocked service. Mocked service should mock a
    ///   UserNotConfirmedException response
    ///
    /// - When:
    ///    - I invoke changePassword with old password and new password
    /// - Then:
    ///    - I should get a .service error with .userNotConfirmed error as underlyingError
    ///
    func testChangePasswordWithUserNotConfirmedException() async throws {

        self.mockIdentityProvider = MockIdentityProvider(mockChangePasswordOutputResponse: { _ in
            throw UserNotConfirmedException(name: nil, message: "user not confirmed exception", httpURLResponse: .init())
        })
        do {
            try await plugin.update(oldPassword: "old password", to: "new password")
            XCTFail("Should return an error if the result from service is invalid")
        } catch {
            guard case AuthError.service(_, _, let underlyingError) = error else {
                XCTFail("Should produce service error instead of \(error)")
                return
            }
            guard case .userNotConfirmed = (underlyingError as? AWSCognitoAuthError) else {
                XCTFail("Underlying error should be userNotConfirmed \(error)")
                return
            }
        }
    }

    /// Test a changePassword call with UserNotFound response from service
    ///
    /// - Given: an auth plugin with mocked service. Mocked service should mock a
    ///   UserNotFoundException response
    ///
    /// - When:
    ///    - I invoke changePassword with old password and new password
    /// - Then:
    ///    - I should get a .userNotFound error
    ///
    func testChangePasswordWithUserNotFoundException() async throws {

        self.mockIdentityProvider = MockIdentityProvider(mockChangePasswordOutputResponse: { _ in
            throw UserNotFoundException(name: nil, message: "user not found exception", httpURLResponse: .init())
        })
        do {
            try await plugin.update(oldPassword: "old password", to: "new password")
            XCTFail("Should return an error if the result from service is invalid")
        } catch {
            guard case AuthError.service(_, _, let underlyingError) = error else {
                XCTFail("Should produce service error instead of \(error)")
                return
            }
            guard case .userNotFound = (underlyingError as? AWSCognitoAuthError) else {
                XCTFail("Underlying error should be userNotFound \(error)")
                return
            }
        }
    }
}
