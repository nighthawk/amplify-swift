//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
@testable import AWSCognitoAuthPlugin

extension SignUpInput: Decodable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let username = try values.decode(String.self, forKey: .username)
        let password = try values.decode(String.self, forKey: .password)
        let clientId = try values.decode(String.self, forKey: .clientId)

        self.init(
            clientId: clientId,
            password: password,
            username: username
        )
    }
}
