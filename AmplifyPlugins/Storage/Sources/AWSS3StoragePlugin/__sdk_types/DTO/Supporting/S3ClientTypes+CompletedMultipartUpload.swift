//
//  File.swift
//  
//
//  Created by Saultz, Ian on 10/30/23.
//

import Foundation

extension S3ClientTypes {
    /// The container for the completed multipart upload details.
    struct CompletedMultipartUpload: Equatable, Encodable {
        /// Array of CompletedPart data types. If you do not supply a valid Part with your request, the service sends back an HTTP 400 response.
        var parts: [S3ClientTypes.CompletedPart]?


//        var xml: String {
//            parts?.compactMap { part in
//            """
//            <Part>
//              \(part.checksumCRC32.map { "<ChecksumCRC32>\($0)</ChecksumCRC32>"})
//              <ChecksumCRC32C>string</ChecksumCRC32C>
//              <ChecksumSHA1>string</ChecksumSHA1>
//              <ChecksumSHA256>string</ChecksumSHA256>
//              <ETag>string</ETag>
//              <PartNumber>integer</PartNumber>
//            </Part>
//            """
//            }.joined() ?? ""
//        }
    }
}
