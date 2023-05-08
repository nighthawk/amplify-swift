//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import Amplify
import Combine

final class PredictionsIdentifyTextTestCase: PredictionsDocumentationBaseTestCase {
    override func setUp() {
        super.setUp()
        predictionsPlugin._detectTextInDocument = .init { _, _ in
            return .init(
                fullText: "",
                words: [],
                rawLineText: [],
                identifiedLines: [],
                selections: [],
                tables: [],
                keyValues: []
            )
        }
    }

    func test_identityTextInDocument() async throws {
        // #-----# identify_text_in_document #-----#
        func detectDocumentText(_ image: URL) async throws -> Predictions.Identify.DocumentText.Result {
            do {
                let result = try await Amplify.Predictions.identify(
                    .textInDocument(textFormatType: .form), in: image
                )
                print("Identified document text: \(result)")
                return result
            } catch let error as PredictionsError {
                print("Error identifying text in document: \(error)")
                throw error
            } catch {
                print("Unexpected error: \(error)")
                throw error
            }
        }
        // #-----------#

        _ = try await detectDocumentText(URL(string: "foo.bar")!)
    }

    func test_combine_identityTextInDocument() async throws {
        // #-----# identify_text_in_document_combine #-----#
        func detectDocumentText(_ image: URL) -> AnyCancellable {
            Amplify.Publisher.create {
                try await Amplify.Predictions.identify(
                    .textInDocument(textFormatType: .form), in: image
                )
            }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error identifying text in document: \(error)")
                }
            }, receiveValue: { value in
                print("Identified text in document: \(value)")
            })
        }
        // #-----------#

        _ = detectDocumentText(URL(string: "foo.bar")!)
    }
}
