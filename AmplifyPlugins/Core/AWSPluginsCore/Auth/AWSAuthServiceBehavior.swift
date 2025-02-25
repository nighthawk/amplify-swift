//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify
import AWSClientRuntime

public protocol AWSAuthServiceBehavior: AnyObject {

    func getCredentialsProvider() -> CredentialsProviding

    func getTokenClaims(tokenString: String) -> Result<[String: AnyObject], AuthError>

    /// Retrieves the identity identifier of for the Auth service
    func getIdentityID() async throws -> String
    
    /// Retrieves the token from the Auth token provider
    func getUserPoolAccessToken() async throws -> String
}
