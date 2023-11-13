//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

@_spi(InternalAWSPinpoint) @testable import InternalAWSPinpoint
import XCTest

//class PinpointRequestsRegistryTests: XCTestCase {
//    private var mockedHttpSdkClient: MockHttpClientEngine!
//    private var pinpointConfiguration: PinpointClientConfiguration!
//
//    override func setUpWithError() throws {
//        mockedHttpSdkClient = MockHttpClientEngine()
//        pinpointConfiguration = .init(region: "us-east-1", credentialsProvider: .mock)
//    }
//
//    func testSetCustomHttpEngine_shouldReplaceConfigurationHttpEngine() throws {
//        let oldHttpClientEngine = pinpointConfiguration.httpClientEngine
//        PinpointRequestsRegistry.shared.setCustomHttpEngine(on: pinpointConfiguration)
//
//        XCTAssertNotEqual(oldHttpClientEngine.typeString,
//                          pinpointConfiguration.httpClientEngine.typeString)
//    }
//
//    func testExecute_withSourcesRegistered_shouldAppendSuffixToUserAgent() async throws {
//        PinpointRequestsRegistry.shared.setCustomHttpEngine(on: pinpointConfiguration)
//
//        await PinpointRequestsRegistry.shared.registerSource(.analytics, for: .recordEvent)
//        await PinpointRequestsRegistry.shared.registerSource(.pushNotifications, for: .recordEvent)
//        let sdkRequest = try createSdkRequest(for: .recordEvent)
//        _ = try await httpClientEngine.execute(request: sdkRequest)
//        let executedRequest = mockedHttpSdkClient.request
//
//        XCTAssertEqual(mockedHttpSdkClient.executeCount, 1)
//        let userAgent = try XCTUnwrap(
//            executedRequest?.headers.value(for: "User-Agent")
//        )
//        XCTAssertTrue(userAgent.contains(AWSPinpointSource.analytics.rawValue))
//        XCTAssertTrue(userAgent.contains(AWSPinpointSource.pushNotifications.rawValue))
//    }
//
//    func testExecute_withoutSourcesRegistered_shouldNotAppendSuffixToUserAgent() async throws {
//        PinpointRequestsRegistry.shared.setCustomHttpEngine(on: pinpointConfiguration)
//
//        await PinpointRequestsRegistry.shared.registerSource(.analytics, for: .recordEvent)
//        await PinpointRequestsRegistry.shared.registerSource(.pushNotifications, for: .recordEvent)
//        let sdkRequest = try createSdkRequest(for: nil)
//        let oldUserAgent = sdkRequest.headers.value(for: "User-Agent")
//
//        _ = try await httpClientEngine.execute(request: sdkRequest)
//        let executedRequest = mockedHttpSdkClient.request
//
//        XCTAssertEqual(mockedHttpSdkClient.executeCount, 1)
//        let newUserAgent = try XCTUnwrap(
//            executedRequest?.headers.value(for: "User-Agent")
//        )
//
//        XCTAssertEqual(newUserAgent, oldUserAgent)
//        XCTAssertFalse(newUserAgent.contains(AWSPinpointSource.analytics.rawValue))
//        XCTAssertFalse(newUserAgent.contains(AWSPinpointSource.pushNotifications.rawValue))
//    }
//
//    private var httpClientEngine: HttpClientEngine {
//        pinpointConfiguration.httpClientEngine
//    }
//
//    private func createSdkRequest(for api: PinpointRequestsRegistry.API?) throws -> SdkHttpRequest {
//        let apiPath = api?.rawValue ?? "otherApi"
//        let endpoint = try Endpoint(
//            urlString: "https://host:42/path/\(apiPath)/suffix",
//            headers: .init(["User-Agent": "mocked_user_agent"])
//        )
//        return SdkHttpRequest(
//            method: .put,
//            endpoint: endpoint
//        )
//    }
//}

