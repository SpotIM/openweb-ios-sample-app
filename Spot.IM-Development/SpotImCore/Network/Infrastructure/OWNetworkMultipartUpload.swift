//
//  MultipartUpload.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

/// Internal type which encapsulates a `MultipartFormData` upload.
class OWNetworkMultipartUpload {
    lazy var result = Result { try build() }

    @OWProtected
    private(set) var multipartFormData: OWNetworkMultipartFormData
    let encodingMemoryThreshold: UInt64
    let request: OWNetworkURLRequestConvertible
    let fileManager: FileManager

    init(encodingMemoryThreshold: UInt64,
         request: OWNetworkURLRequestConvertible,
         multipartFormData: OWNetworkMultipartFormData) {
        self.encodingMemoryThreshold = encodingMemoryThreshold
        self.request = request
        fileManager = multipartFormData.fileManager
        self.multipartFormData = multipartFormData
    }

    func build() throws -> OWNetworkUploadRequest.Uploadable {
        let uploadable: OWNetworkUploadRequest.Uploadable
        if $multipartFormData.contentLength < encodingMemoryThreshold {
            let data = try $multipartFormData.read { try $0.encode() }

            uploadable = .data(data)
        } else {
            let tempDirectoryURL = fileManager.temporaryDirectory
            let directoryURL = tempDirectoryURL.appendingPathComponent("org.OpenWebSDKNetwork.manager/multipart.form.data")
            let fileName = UUID().uuidString
            let fileURL = directoryURL.appendingPathComponent(fileName)

            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)

            do {
                try $multipartFormData.read { try $0.writeEncodedData(to: fileURL) }
            } catch {
                // Cleanup after attempted write if it fails.
                try? fileManager.removeItem(at: fileURL)
                throw error
            }

            uploadable = .file(fileURL, shouldRemove: true)
        }

        return uploadable
    }
}

extension OWNetworkMultipartUpload: OWNetworkUploadConvertible {
    func asURLRequest() throws -> URLRequest {
        var urlRequest = try request.asURLRequest()

        $multipartFormData.read { multipartFormData in
            urlRequest.headers.add(.contentType(multipartFormData.contentType))
        }

        return urlRequest
    }

    func createUploadable() throws -> OWNetworkUploadRequest.Uploadable {
        try result.get()
    }
}
