//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify
import AWSPluginsCore
import AWSCognitoIdentityProvider

class AWSAuthSendUserAttributeVerificationCodeTask: AuthSendUserAttributeVerificationCodeTask, DefaultLogger {
    typealias CognitoUserPoolFactory = () throws -> CognitoUserPoolBehavior

    private let request: AuthSendUserAttributeVerificationCodeRequest
    private let authStateMachine: AuthStateMachine
    private let userPoolFactory: CognitoUserPoolFactory
    private let taskHelper: AWSAuthTaskHelper

    var eventName: HubPayloadEventName {
        HubPayload.EventName.Auth.sendUserAttributeVerificationCodeAPI
    }

    init(_ request: AuthSendUserAttributeVerificationCodeRequest,
         authStateMachine: AuthStateMachine,
         userPoolFactory: @escaping CognitoUserPoolFactory) {
        self.request = request
        self.authStateMachine = authStateMachine
        self.userPoolFactory = userPoolFactory
        self.taskHelper = AWSAuthTaskHelper(authStateMachine: authStateMachine)
    }

    func execute() async throws -> AuthCodeDeliveryDetails {
        do {
            await taskHelper.didStateMachineConfigured()
            let accessToken = try await taskHelper.getAccessToken()
            let devices = try await initiateGettingVerificationCode(with: accessToken)
            return devices
        } catch let error as AuthErrorConvertible {
            throw error.authError
        } catch  {
            throw AuthError.configuration(
                "Unable to execute auth task",
                AuthPluginErrorConstants.configurationError,
                error
            )
        }
    }

    func initiateGettingVerificationCode(with accessToken: String) async throws -> AuthCodeDeliveryDetails {
        let userPoolService = try userPoolFactory()
        let clientMetaData = (request.options.pluginOptions as? AWSSendUserAttributeVerificationCodeOptions)?.metadata ?? [:]

        let input = GetUserAttributeVerificationCodeInput(
            accessToken: accessToken,
            attributeName: request.attributeKey.rawValue,
            clientMetadata: clientMetaData)

        let result = try await userPoolService.getUserAttributeVerificationCode(input: input)
        guard let deliveryDetails = result.codeDeliveryDetails?.toAuthCodeDeliveryDetails() else {
            let authError = AuthError.unknown("Unable to get Auth code delivery details", nil)
            throw authError
        }
        return deliveryDetails
    }
}
