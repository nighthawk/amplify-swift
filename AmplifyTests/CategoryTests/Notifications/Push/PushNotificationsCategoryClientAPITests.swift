//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

@testable import Amplify
@testable import AmplifyTestCommon
import UserNotifications
import XCTest

class PushNotificationsCategoryClientAPITests: XCTestCase {
    private var category: PushNotificationsCategory!
    private var plugin: MockPushNotificationsCategoryPlugin!

    override func setUp() async throws {
        await Amplify.reset()
        category = Amplify.Notifications.Push
        plugin = MockPushNotificationsCategoryPlugin()
        
        let categoryConfiguration = NotificationsCategoryConfiguration(
            plugins: ["MockPushNotificationsCategoryPlugin": true]
        )
        
        let amplifyConfiguration = AmplifyConfiguration(notifications: categoryConfiguration)
        try Amplify.add(plugin: plugin)
        try Amplify.configure(amplifyConfiguration)
    }

    override func tearDown() async throws {
        await Amplify.reset()
        category = nil
        plugin = nil
    }

    func testIdentifyUser_shouldSucceed() async throws {
        let expectedMessage = "identifyUser(userId:test)"
        var methodInvoked = false
        plugin.listeners.append { message in
            if message == expectedMessage {
                methodInvoked = true
            }
        }

        try await category.identifyUser(userId: "test")
        XCTAssertTrue(methodInvoked)
    }

    func testRegisterDeviceToken_shouldSucceed() async throws {
        let data = "Data".data(using: .utf8)!
        let expectedMessage = "registerDevice(token:\(data))"
        var methodInvoked = false
        plugin.listeners.append { message in
            if message == expectedMessage {
                methodInvoked = true
            }
        }

        try await category.registerDevice(apnsToken: data)
        XCTAssertTrue(methodInvoked)
    }

    func testRecordNotificationReceived_shouldSucceed() async throws {
        let userInfo: Notifications.Push.UserInfo = ["test": "test"]
        let expectedMessage = "recordNotificationReceived(userInfo:\(userInfo))"
        var methodInvoked = false
        plugin.listeners.append { message in
            if message == expectedMessage {
                methodInvoked = true
            }
        }

        try await category.recordNotificationReceived(userInfo)
        XCTAssertTrue(methodInvoked)
    }

#if !os(tvOS)
    func testRecordNotificationOpened_shouldSucceed() async throws {
        let response = UNNotificationResponse(coder: MockedKeyedArchiver(requiringSecureCoding: false))!
        let expectedMessage = "recordNotificationOpened(response:\(response))"
        var methodInvoked = false
        plugin.listeners.append { message in
            if message == expectedMessage {
                methodInvoked = true
            }
        }

        try await category.recordNotificationOpened(response)
        XCTAssertTrue(methodInvoked)
    }
#endif

    private class MockedKeyedArchiver: NSKeyedArchiver {
        override func decodeObject(forKey _: String) -> Any { "" }
        override func decodeInt64(forKey key: String) -> Int64 { 0 }
    }
}
