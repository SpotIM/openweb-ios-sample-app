//
//  Concurrency.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

// we might delete it entierly

#if compiler(>=5.6.0) && canImport(_Concurrency)

import Foundation

// MARK: - Request Event Streams

@available(iOS 13, *)
extension OWNetworkRequest {
    /// Creates a `StreamOf<Progress>` for the instance's upload progress.
    ///
    /// - Parameter bufferingPolicy: `BufferingPolicy` that determines the stream's buffering behavior.`.unbounded` by default.
    ///
    /// - Returns:                   The `StreamOf<Progress>`.
    func uploadProgress(bufferingPolicy: OWNetworkStreamOf<Progress>.BufferingPolicy = .unbounded) -> OWNetworkStreamOf<Progress> {
        stream(bufferingPolicy: bufferingPolicy) { [unowned self] continuation in
            uploadProgress(queue: .singleEventQueue) { progress in
                continuation.yield(progress)
            }
        }
    }

    /// Creates a `StreamOf<Progress>` for the instance's download progress.
    ///
    /// - Parameter bufferingPolicy: `BufferingPolicy` that determines the stream's buffering behavior.`.unbounded` by default.
    ///
    /// - Returns:                   The `StreamOf<Progress>`.
    func downloadProgress(bufferingPolicy: OWNetworkStreamOf<Progress>.BufferingPolicy = .unbounded) -> OWNetworkStreamOf<Progress> {
        stream(bufferingPolicy: bufferingPolicy) { [unowned self] continuation in
            downloadProgress(queue: .singleEventQueue) { progress in
                continuation.yield(progress)
            }
        }
    }

    /// Creates a `StreamOf<URLRequest>` for the `URLRequest`s produced for the instance.
    ///
    /// - Parameter bufferingPolicy: `BufferingPolicy` that determines the stream's buffering behavior.`.unbounded` by default.
    ///
    /// - Returns:                   The `StreamOf<URLRequest>`.
    func urlRequests(bufferingPolicy: OWNetworkStreamOf<URLRequest>.BufferingPolicy = .unbounded) -> OWNetworkStreamOf<URLRequest> {
        stream(bufferingPolicy: bufferingPolicy) { [unowned self] continuation in
            onURLRequestCreation(on: .singleEventQueue) { request in
                continuation.yield(request)
            }
        }
    }

    /// Creates a `StreamOf<URLSessionTask>` for the `URLSessionTask`s produced for the instance.
    ///
    /// - Parameter bufferingPolicy: `BufferingPolicy` that determines the stream's buffering behavior.`.unbounded` by default.
    ///
    /// - Returns:                   The `StreamOf<URLSessionTask>`.
    func urlSessionTasks(bufferingPolicy: OWNetworkStreamOf<URLSessionTask>.BufferingPolicy = .unbounded) -> OWNetworkStreamOf<URLSessionTask> {
        stream(bufferingPolicy: bufferingPolicy) { [unowned self] continuation in
            onURLSessionTaskCreation(on: .singleEventQueue) { task in
                continuation.yield(task)
            }
        }
    }

    /// Creates a `StreamOf<String>` for the cURL descriptions produced for the instance.
    ///
    /// - Parameter bufferingPolicy: `BufferingPolicy` that determines the stream's buffering behavior.`.unbounded` by default.
    ///
    /// - Returns:                   The `StreamOf<String>`.
    func cURLDescriptions(bufferingPolicy: OWNetworkStreamOf<String>.BufferingPolicy = .unbounded) -> OWNetworkStreamOf<String> {
        stream(bufferingPolicy: bufferingPolicy) { [unowned self] continuation in
            cURLDescription(on: .singleEventQueue) { description in
                continuation.yield(description)
            }
        }
    }

    private func stream<T>(of type: T.Type = T.self,
                           bufferingPolicy: OWNetworkStreamOf<T>.BufferingPolicy = .unbounded,
                           yielder: @escaping (OWNetworkStreamOf<T>.Continuation) -> Void) -> OWNetworkStreamOf<T> {
        OWNetworkStreamOf<T>(bufferingPolicy: bufferingPolicy) { [unowned self] continuation in
            yielder(continuation)
            // Must come after serializers run in order to catch retry progress.
            onFinish {
                continuation.finish()
            }
        }
    }
}

// MARK: - DataTask

/// Value used to `await` a `DataResponse` and associated values.
@available(iOS 13, *)
struct OWNetworkDataTask<Value> {
    /// `DataResponse` produced by the `DataRequest` and its response handler.
    var response: OWNetworkDataResponse<Value, OWNetworkError> {
        get async {
            if shouldAutomaticallyCancel {
                return await withTaskCancellationHandler {
                    self.cancel()
                } operation: {
                    await task.value
                }
            } else {
                return await task.value
            }
        }
    }

    /// `Result` of any response serialization performed for the `response`.
    var result: Result<Value, OWNetworkError> {
        get async { await response.result }
    }

    /// `Value` returned by the `response`.
    var value: Value {
        get async throws {
            try await result.get()
        }
    }

    private let request: OWNetworkDataRequest
    private let task: Task<OWNetworkDataResponse<Value, OWNetworkError>, Never>
    private let shouldAutomaticallyCancel: Bool

    fileprivate init(request: OWNetworkDataRequest, task: Task<OWNetworkDataResponse<Value, OWNetworkError>, Never>, shouldAutomaticallyCancel: Bool) {
        self.request = request
        self.task = task
        self.shouldAutomaticallyCancel = shouldAutomaticallyCancel
    }

    /// Cancel the underlying `DataRequest` and `Task`.
    func cancel() {
        task.cancel()
    }

    /// Resume the underlying `DataRequest`.
    func resume() {
        request.resume()
    }

    /// Suspend the underlying `DataRequest`.
    func suspend() {
        request.suspend()
    }
}

@available(iOS 13, *)
extension OWNetworkDataRequest {
    /// Creates a `DataTask` to `await` a `Data` value.
    ///
    /// - Parameters:
    ///   - shouldAutomaticallyCancel: `Bool` determining whether or not the request should be cancelled when the
    ///                                enclosing async context is cancelled. Only applies to `DataTask`'s async
    ///                                properties. `false` by default.
    ///   - dataPreprocessor:          `DataPreprocessor` which processes the received `Data` before completion.
    ///   - emptyResponseCodes:        HTTP response codes for which empty responses are allowed. `[204, 205]` by default.
    ///   - emptyRequestMethods:       `HTTPMethod`s for which empty responses are always valid. `[.head]` by default.
    ///
    /// - Returns: The `DataTask`.
    func serializingData(automaticallyCancelling shouldAutomaticallyCancel: Bool = false,
                         dataPreprocessor: OWNetworkDataPreprocessor = OWNetworkDataResponseSerializer.defaultDataPreprocessor,
                         emptyResponseCodes: Set<Int> = OWNetworkDataResponseSerializer.defaultEmptyResponseCodes,
                         emptyRequestMethods: Set<OWNetworkHTTPMethod> = OWNetworkDataResponseSerializer.defaultEmptyRequestMethods) -> OWNetworkDataTask<Data> {
        serializingResponse(using: OWNetworkDataResponseSerializer(dataPreprocessor: dataPreprocessor,
                                                                   emptyResponseCodes: emptyResponseCodes,
                                                                   emptyRequestMethods: emptyRequestMethods),
                            automaticallyCancelling: shouldAutomaticallyCancel)
    }

    /// Creates a `DataTask` to `await` serialization of a `Decodable` value.
    ///
    /// - Parameters:
    ///   - type:                      `Decodable` type to decode from response data.
    ///   - shouldAutomaticallyCancel: `Bool` determining whether or not the request should be cancelled when the
    ///                                enclosing async context is cancelled. Only applies to `DataTask`'s async
    ///                                properties. `false` by default.
    ///   - dataPreprocessor:          `DataPreprocessor` which processes the received `Data` before calling the serializer.
    ///                                `PassthroughPreprocessor()` by default.
    ///   - decoder:                   `DataDecoder` to use to decode the response. `JSONDecoder()` by default.
    ///   - emptyResponseCodes:        HTTP status codes for which empty responses are always valid. `[204, 205]` by default.
    ///   - emptyRequestMethods:       `HTTPMethod`s for which empty responses are always valid. `[.head]` by default.
    ///
    /// - Returns: The `DataTask`.
    func serializingDecodable<Value: Decodable>(_ type: Value.Type = Value.self,
                                                automaticallyCancelling shouldAutomaticallyCancel: Bool = false,
                                                dataPreprocessor: OWNetworkDataPreprocessor = OWNetworkDecodableResponseSerializer<Value>.defaultDataPreprocessor,
                                                decoder: OWNetworkDataDecoder = JSONDecoder(),
                                                emptyResponseCodes: Set<Int> = OWNetworkDecodableResponseSerializer<Value>.defaultEmptyResponseCodes,
                                                emptyRequestMethods: Set<OWNetworkHTTPMethod> = OWNetworkDecodableResponseSerializer<Value>.defaultEmptyRequestMethods)
    -> OWNetworkDataTask<Value> {
        serializingResponse(using: OWNetworkDecodableResponseSerializer<Value>(dataPreprocessor: dataPreprocessor,
                                                                               decoder: decoder,
                                                                               emptyResponseCodes: emptyResponseCodes,
                                                                               emptyRequestMethods: emptyRequestMethods),
                            automaticallyCancelling: shouldAutomaticallyCancel)
    }

    /// Creates a `DataTask` to `await` serialization of a `String` value.
    ///
    /// - Parameters:
    ///   - shouldAutomaticallyCancel: `Bool` determining whether or not the request should be cancelled when the
    ///                                enclosing async context is cancelled. Only applies to `DataTask`'s async
    ///                                properties. `false` by default.
    ///   - dataPreprocessor:          `DataPreprocessor` which processes the received `Data` before calling the serializer.
    ///                                `PassthroughPreprocessor()` by default.
    ///   - encoding:                  `String.Encoding` to use during serialization. Defaults to `nil`, in which case
    ///                                the encoding will be determined from the server response, falling back to the
    ///                                default HTTP character set, `ISO-8859-1`.
    ///   - emptyResponseCodes:        HTTP status codes for which empty responses are always valid. `[204, 205]` by default.
    ///   - emptyRequestMethods:       `HTTPMethod`s for which empty responses are always valid. `[.head]` by default.
    ///
    /// - Returns: The `DataTask`.
    func serializingString(automaticallyCancelling shouldAutomaticallyCancel: Bool = false,
                           dataPreprocessor: OWNetworkDataPreprocessor = OWNetworkStringResponseSerializer.defaultDataPreprocessor,
                           encoding: String.Encoding? = nil,
                           emptyResponseCodes: Set<Int> = OWNetworkStringResponseSerializer.defaultEmptyResponseCodes,
                           emptyRequestMethods: Set<OWNetworkHTTPMethod> = OWNetworkStringResponseSerializer.defaultEmptyRequestMethods) -> OWNetworkDataTask<String> {
        serializingResponse(using: OWNetworkStringResponseSerializer(dataPreprocessor: dataPreprocessor,
                                                                     encoding: encoding,
                                                                     emptyResponseCodes: emptyResponseCodes,
                                                                     emptyRequestMethods: emptyRequestMethods),
                            automaticallyCancelling: shouldAutomaticallyCancel)
    }

    /// Creates a `DataTask` to `await` serialization using the provided `ResponseSerializer` instance.
    ///
    /// - Parameters:
    ///   - serializer:                `ResponseSerializer` responsible for serializing the request, response, and data.
    ///   - shouldAutomaticallyCancel: `Bool` determining whether or not the request should be cancelled when the
    ///                                enclosing async context is cancelled. Only applies to `DataTask`'s async
    ///                                properties. `false` by default.
    ///
    /// - Returns: The `DataTask`.
    func serializingResponse<Serializer: OWNetworkResponseSerializer>(using serializer: Serializer,
                                                                      automaticallyCancelling shouldAutomaticallyCancel: Bool = false)
    -> OWNetworkDataTask<Serializer.SerializedObject> {
        dataTask(automaticallyCancelling: shouldAutomaticallyCancel) {
            self.response(queue: .singleEventQueue,
                          responseSerializer: serializer,
                          completionHandler: $0)
        }
    }

    /// Creates a `DataTask` to `await` serialization using the provided `DataResponseSerializerProtocol` instance.
    ///
    /// - Parameters:
    ///   - serializer:                `DataResponseSerializerProtocol` responsible for serializing the request,
    ///                                response, and data.
    ///   - shouldAutomaticallyCancel: `Bool` determining whether or not the request should be cancelled when the
    ///                                enclosing async context is cancelled. Only applies to `DataTask`'s async
    ///                                properties. `false` by default.
    ///
    /// - Returns: The `DataTask`.
    func serializingResponse<Serializer: OWNetworkDataResponseSerializerProtocol>(using serializer: Serializer,
                                                                                  automaticallyCancelling shouldAutomaticallyCancel: Bool = false)
    -> OWNetworkDataTask<Serializer.SerializedObject> {
        dataTask(automaticallyCancelling: shouldAutomaticallyCancel) {
            self.response(queue: .singleEventQueue,
                          responseSerializer: serializer,
                          completionHandler: $0)
        }
    }

    private func dataTask<Value>(automaticallyCancelling shouldAutomaticallyCancel: Bool,
                                 forResponse onResponse: @escaping (@escaping (OWNetworkDataResponse<Value, OWNetworkError>) -> Void) -> Void)
    -> OWNetworkDataTask<Value> {
        let task = Task {
            await withTaskCancellationHandler {
                self.cancel()
            } operation: {
                await withCheckedContinuation { continuation in
                    onResponse {
                        continuation.resume(returning: $0)
                    }
                }
            }
        }

        return OWNetworkDataTask<Value>(request: self, task: task, shouldAutomaticallyCancel: shouldAutomaticallyCancel)
    }
}

// MARK: - DownloadTask

/// Value used to `await` a `DownloadResponse` and associated values.
@available(iOS 13, *)
struct OWNetworkDownloadTask<Value> {
    /// `DownloadResponse` produced by the `DownloadRequest` and its response handler.
    var response: OWNetworkDownloadResponse<Value, OWNetworkError> {
        get async {
            if shouldAutomaticallyCancel {
                return await withTaskCancellationHandler {
                    self.cancel()
                } operation: {
                    await task.value
                }
            } else {
                return await task.value
            }
        }
    }

    /// `Result` of any response serialization performed for the `response`.
    var result: Result<Value, OWNetworkError> {
        get async { await response.result }
    }

    /// `Value` returned by the `response`.
    var value: Value {
        get async throws {
            try await result.get()
        }
    }

    private let task: Task<OWNetworkDownloadResponseTypealias<Value>, Never>
    private let request: OWNetworkDownloadRequest
    private let shouldAutomaticallyCancel: Bool

    fileprivate init(request: OWNetworkDownloadRequest, task: Task<OWNetworkDownloadResponseTypealias<Value>, Never>, shouldAutomaticallyCancel: Bool) {
        self.request = request
        self.task = task
        self.shouldAutomaticallyCancel = shouldAutomaticallyCancel
    }

    /// Cancel the underlying `DownloadRequest` and `Task`.
    func cancel() {
        task.cancel()
    }

    /// Resume the underlying `DownloadRequest`.
    func resume() {
        request.resume()
    }

    /// Suspend the underlying `DownloadRequest`.
    func suspend() {
        request.suspend()
    }
}

@available(iOS 13, *)
extension OWNetworkDownloadRequest {
    /// Creates a `DownloadTask` to `await` a `Data` value.
    ///
    /// - Parameters:
    ///   - shouldAutomaticallyCancel: `Bool` determining whether or not the request should be cancelled when the
    ///                                enclosing async context is cancelled. Only applies to `DownloadTask`'s async
    ///                                properties. `false` by default.
    ///   - dataPreprocessor:          `DataPreprocessor` which processes the received `Data` before completion.
    ///   - emptyResponseCodes:        HTTP response codes for which empty responses are allowed. `[204, 205]` by default.
    ///   - emptyRequestMethods:       `HTTPMethod`s for which empty responses are always valid. `[.head]` by default.
    ///
    /// - Returns:                   The `DownloadTask`.
    func serializingData(automaticallyCancelling shouldAutomaticallyCancel: Bool = false,
                         dataPreprocessor: OWNetworkDataPreprocessor = OWNetworkDataResponseSerializer.defaultDataPreprocessor,
                         emptyResponseCodes: Set<Int> = OWNetworkDataResponseSerializer.defaultEmptyResponseCodes,
                         emptyRequestMethods: Set<OWNetworkHTTPMethod> = OWNetworkDataResponseSerializer.defaultEmptyRequestMethods)
    -> OWNetworkDownloadTask<Data> {
        serializingDownload(using: OWNetworkDataResponseSerializer(dataPreprocessor: dataPreprocessor,
                                                                   emptyResponseCodes: emptyResponseCodes,
                                                                   emptyRequestMethods: emptyRequestMethods),
                            automaticallyCancelling: shouldAutomaticallyCancel)
    }

    /// Creates a `DownloadTask` to `await` serialization of a `Decodable` value.
    ///
    /// - Note: This serializer reads the entire response into memory before parsing.
    ///
    /// - Parameters:
    ///   - type:                      `Decodable` type to decode from response data.
    ///   - shouldAutomaticallyCancel: `Bool` determining whether or not the request should be cancelled when the
    ///                                enclosing async context is cancelled. Only applies to `DownloadTask`'s async
    ///                                properties. `false` by default.
    ///   - dataPreprocessor:          `DataPreprocessor` which processes the received `Data` before calling the serializer.
    ///                                `PassthroughPreprocessor()` by default.
    ///   - decoder:                   `DataDecoder` to use to decode the response. `JSONDecoder()` by default.
    ///   - emptyResponseCodes:        HTTP status codes for which empty responses are always valid. `[204, 205]` by default.
    ///   - emptyRequestMethods:       `HTTPMethod`s for which empty responses are always valid. `[.head]` by default.
    ///
    /// - Returns:                   The `DownloadTask`.
    func serializingDecodable<Value: Decodable>(_ type: Value.Type = Value.self,
                                                automaticallyCancelling shouldAutomaticallyCancel: Bool = false,
                                                dataPreprocessor: OWNetworkDataPreprocessor = OWNetworkDecodableResponseSerializer<Value>.defaultDataPreprocessor,
                                                decoder: OWNetworkDataDecoder = JSONDecoder(),
                                                emptyResponseCodes: Set<Int> = OWNetworkDecodableResponseSerializer<Value>.defaultEmptyResponseCodes,
                                                emptyRequestMethods: Set<OWNetworkHTTPMethod> = OWNetworkDecodableResponseSerializer<Value>.defaultEmptyRequestMethods)
    -> OWNetworkDownloadTask<Value> {
        serializingDownload(using: OWNetworkDecodableResponseSerializer<Value>(dataPreprocessor: dataPreprocessor,
                                                                               decoder: decoder,
                                                                               emptyResponseCodes: emptyResponseCodes,
                                                                               emptyRequestMethods: emptyRequestMethods),
                            automaticallyCancelling: shouldAutomaticallyCancel)
    }

    /// Creates a `DownloadTask` to `await` serialization of the downloaded file's `URL` on disk.
    ///
    /// - Parameters:
    ///   - shouldAutomaticallyCancel: `Bool` determining whether or not the request should be cancelled when the
    ///                                enclosing async context is cancelled. Only applies to `DownloadTask`'s async
    ///                                properties. `false` by default.
    ///
    /// - Returns: The `DownloadTask`.
    func serializingDownloadedFileURL(automaticallyCancelling shouldAutomaticallyCancel: Bool = false) -> OWNetworkDownloadTask<URL> {
        serializingDownload(using: OWNetworkURLResponseSerializer(),
                            automaticallyCancelling: shouldAutomaticallyCancel)
    }

    /// Creates a `DownloadTask` to `await` serialization of a `String` value.
    ///
    /// - Parameters:
    ///   - shouldAutomaticallyCancel: `Bool` determining whether or not the request should be cancelled when the
    ///                                enclosing async context is cancelled. Only applies to `DownloadTask`'s async
    ///                                properties. `false` by default.
    ///   - dataPreprocessor:          `DataPreprocessor` which processes the received `Data` before calling the
    ///                                serializer. `PassthroughPreprocessor()` by default.
    ///   - encoding:                  `String.Encoding` to use during serialization. Defaults to `nil`, in which case
    ///                                the encoding will be determined from the server response, falling back to the
    ///                                default HTTP character set, `ISO-8859-1`.
    ///   - emptyResponseCodes:        HTTP status codes for which empty responses are always valid. `[204, 205]` by default.
    ///   - emptyRequestMethods:       `HTTPMethod`s for which empty responses are always valid. `[.head]` by default.
    ///
    /// - Returns:                   The `DownloadTask`.
    func serializingString(automaticallyCancelling shouldAutomaticallyCancel: Bool = false,
                           dataPreprocessor: OWNetworkDataPreprocessor = OWNetworkStringResponseSerializer.defaultDataPreprocessor,
                           encoding: String.Encoding? = nil,
                           emptyResponseCodes: Set<Int> = OWNetworkStringResponseSerializer.defaultEmptyResponseCodes,
                           emptyRequestMethods: Set<OWNetworkHTTPMethod> = OWNetworkStringResponseSerializer.defaultEmptyRequestMethods)
    -> OWNetworkDownloadTask<String> {
        serializingDownload(using: OWNetworkStringResponseSerializer(dataPreprocessor: dataPreprocessor,
                                                                     encoding: encoding,
                                                                     emptyResponseCodes: emptyResponseCodes,
                                                                     emptyRequestMethods: emptyRequestMethods),
                            automaticallyCancelling: shouldAutomaticallyCancel)
    }

    /// Creates a `DownloadTask` to `await` serialization using the provided `ResponseSerializer` instance.
    ///
    /// - Parameters:
    ///   - serializer:                `ResponseSerializer` responsible for serializing the request, response, and data.
    ///   - shouldAutomaticallyCancel: `Bool` determining whether or not the request should be cancelled when the
    ///                                enclosing async context is cancelled. Only applies to `DownloadTask`'s async
    ///                                properties. `false` by default.
    ///
    /// - Returns: The `DownloadTask`.
    func serializingDownload<Serializer: OWNetworkResponseSerializer>(using serializer: Serializer,
                                                                      automaticallyCancelling shouldAutomaticallyCancel: Bool = false)
    -> OWNetworkDownloadTask<Serializer.SerializedObject> {
        downloadTask(automaticallyCancelling: shouldAutomaticallyCancel) {
            self.response(queue: .singleEventQueue,
                          responseSerializer: serializer,
                          completionHandler: $0)
        }
    }

    /// Creates a `DownloadTask` to `await` serialization using the provided `DownloadResponseSerializerProtocol`
    /// instance.
    ///
    /// - Parameters:
    ///   - serializer:                `DownloadResponseSerializerProtocol` responsible for serializing the request,
    ///                                response, and data.
    ///   - shouldAutomaticallyCancel: `Bool` determining whether or not the request should be cancelled when the
    ///                                enclosing async context is cancelled. Only applies to `DownloadTask`'s async
    ///                                properties. `false` by default.
    ///
    /// - Returns: The `DownloadTask`.
    func serializingDownload<Serializer: OWNetworkDownloadResponseSerializerProtocol>(using serializer: Serializer,
                                                                                      automaticallyCancelling shouldAutomaticallyCancel: Bool = false)
    -> OWNetworkDownloadTask<Serializer.SerializedObject> {
        downloadTask(automaticallyCancelling: shouldAutomaticallyCancel) {
            self.response(queue: .singleEventQueue,
                          responseSerializer: serializer,
                          completionHandler: $0)
        }
    }

    private func downloadTask<Value>(automaticallyCancelling shouldAutomaticallyCancel: Bool,
                                     forResponse onResponse: @escaping (@escaping (OWNetworkDownloadResponse<Value, OWNetworkError>) -> Void) -> Void)
    -> OWNetworkDownloadTask<Value> {
        let task = Task {
            await withTaskCancellationHandler {
                self.cancel()
            } operation: {
                await withCheckedContinuation { continuation in
                    onResponse {
                        continuation.resume(returning: $0)
                    }
                }
            }
        }

        return OWNetworkDownloadTask<Value>(request: self, task: task, shouldAutomaticallyCancel: shouldAutomaticallyCancel)
    }
}

// MARK: - DataStreamTask

@available(iOS 13, *)
struct OWNetworkDataStreamTask {
    // Type of created streams.
    typealias Stream<Success, Failure: Error> = OWNetworkStreamOf<OWNetworkDataStreamRequest.Stream<Success, Failure>>

    private let request: OWNetworkDataStreamRequest

    fileprivate init(request: OWNetworkDataStreamRequest) {
        self.request = request
    }

    /// Creates a `Stream` of `Data` values from the underlying `DataStreamRequest`.
    ///
    /// - Parameters:
    ///   - shouldAutomaticallyCancel: `Bool` indicating whether the underlying `DataStreamRequest` should be canceled
    ///                                which observation of the stream stops. `true` by default.
    ///   - bufferingPolicy: `         BufferingPolicy` that determines the stream's buffering behavior.`.unbounded` by default.
    ///
    /// - Returns:                   The `Stream`.
    func streamingData(automaticallyCancelling shouldAutomaticallyCancel: Bool = true,
                       bufferingPolicy: Stream<Data, Never>.BufferingPolicy = .unbounded) -> Stream<Data, Never> {
        createStream(automaticallyCancelling: shouldAutomaticallyCancel, bufferingPolicy: bufferingPolicy) { onStream in
            self.request.responseStream(on: .streamCompletionQueue(forRequestID: request.id), stream: onStream)
        }
    }

    /// Creates a `Stream` of `UTF-8` `String`s from the underlying `DataStreamRequest`.
    ///
    /// - Parameters:
    ///   - shouldAutomaticallyCancel: `Bool` indicating whether the underlying `DataStreamRequest` should be canceled
    ///                                which observation of the stream stops. `true` by default.
    ///   - bufferingPolicy: `         BufferingPolicy` that determines the stream's buffering behavior.`.unbounded` by default.
    /// - Returns:
    func streamingStrings(automaticallyCancelling shouldAutomaticallyCancel: Bool = true,
                          bufferingPolicy: Stream<String, Never>.BufferingPolicy = .unbounded) -> Stream<String, Never> {
        createStream(automaticallyCancelling: shouldAutomaticallyCancel, bufferingPolicy: bufferingPolicy) { onStream in
            self.request.responseStreamString(on: .streamCompletionQueue(forRequestID: request.id), stream: onStream)
        }
    }

    /// Creates a `Stream` of `Decodable` values from the underlying `DataStreamRequest`.
    ///
    /// - Parameters:
    ///   - type:                      `Decodable` type to be serialized from stream payloads.
    ///   - shouldAutomaticallyCancel: `Bool` indicating whether the underlying `DataStreamRequest` should be canceled
    ///                                which observation of the stream stops. `true` by default.
    ///   - bufferingPolicy:           `BufferingPolicy` that determines the stream's buffering behavior.`.unbounded` by default.
    ///
    /// - Returns:            The `Stream`.
    func streamingDecodables<T>(_ type: T.Type = T.self,
                                automaticallyCancelling shouldAutomaticallyCancel: Bool = true,
                                bufferingPolicy: Stream<T, OWNetworkError>.BufferingPolicy = .unbounded)
    -> Stream<T, OWNetworkError> where T: Decodable {
        streamingResponses(serializedUsing: OWNetworkDecodableStreamSerializer<T>(),
                           automaticallyCancelling: shouldAutomaticallyCancel,
                           bufferingPolicy: bufferingPolicy)
    }

    /// Creates a `Stream` of values using the provided `DataStreamSerializer` from the underlying `DataStreamRequest`.
    ///
    /// - Parameters:
    ///   - serializer:                `DataStreamSerializer` to use to serialize incoming `Data`.
    ///   - shouldAutomaticallyCancel: `Bool` indicating whether the underlying `DataStreamRequest` should be canceled
    ///                                which observation of the stream stops. `true` by default.
    ///   - bufferingPolicy:           `BufferingPolicy` that determines the stream's buffering behavior.`.unbounded` by default.
    ///
    /// - Returns:           The `Stream`.
    func streamingResponses<Serializer: OWNetworkDataStreamSerializer>(serializedUsing serializer: Serializer,
                                                                       automaticallyCancelling shouldAutomaticallyCancel: Bool = true,
                                                                       bufferingPolicy: Stream<Serializer.SerializedObject, OWNetworkError>.BufferingPolicy = .unbounded)
    -> Stream<Serializer.SerializedObject, OWNetworkError> {
        createStream(automaticallyCancelling: shouldAutomaticallyCancel, bufferingPolicy: bufferingPolicy) { onStream in
            self.request.responseStream(using: serializer,
                                        on: .streamCompletionQueue(forRequestID: request.id),
                                        stream: onStream)
        }
    }

    private func createStream<Success, Failure: Error>(automaticallyCancelling shouldAutomaticallyCancel: Bool = true,
                                                       bufferingPolicy: Stream<Success, Failure>.BufferingPolicy = .unbounded,
                                                       forResponse onResponse: @escaping (@escaping (OWNetworkDataStreamRequest.Stream<Success, Failure>) -> Void) -> Void)
    -> Stream<Success, Failure> {
        OWNetworkStreamOf(bufferingPolicy: bufferingPolicy) {
            guard shouldAutomaticallyCancel,
                  request.isInitialized || request.isResumed || request.isSuspended else { return }

            cancel()
        } builder: { continuation in
            onResponse { stream in
                continuation.yield(stream)
                if case .complete = stream.event {
                    continuation.finish()
                }
            }
        }
    }

    /// Cancel the underlying `DataStreamRequest`.
    func cancel() {
        request.cancel()
    }

    /// Resume the underlying `DataStreamRequest`.
    func resume() {
        request.resume()
    }

    /// Suspend the underlying `DataStreamRequest`.
    func suspend() {
        request.suspend()
    }
}

@available(iOS 13, *)
extension OWNetworkDataStreamRequest {
    /// Creates a `DataStreamTask` used to `await` streams of serialized values.
    ///
    /// - Returns: The `DataStreamTask`.
    func streamTask() -> OWNetworkDataStreamTask {
        OWNetworkDataStreamTask(request: self)
    }
}

extension DispatchQueue {
    fileprivate static let singleEventQueue = DispatchQueue(label: "OpenWebSDKNetworkConcurrencySingleEventQueue",
                                                            attributes: .concurrent)

    fileprivate static func streamCompletionQueue(forRequestID id: UUID) -> DispatchQueue {
        DispatchQueue(label: "OpenWebSDKNetworkConcurrencyStreamCompletionQueue-\(id)", target: .singleEventQueue)
    }
}

/// An asynchronous sequence generated from an underlying `AsyncStream`. Only produced by OWNetwork.
@available(iOS 13, *)
struct OWNetworkStreamOf<Element>: AsyncSequence {
    typealias AsyncIterator = Iterator
    typealias BufferingPolicy = AsyncStream<Element>.Continuation.BufferingPolicy
    fileprivate typealias Continuation = AsyncStream<Element>.Continuation

    private let bufferingPolicy: BufferingPolicy
    private let onTermination: (() -> Void)?
    private let builder: (Continuation) -> Void

    fileprivate init(bufferingPolicy: BufferingPolicy = .unbounded,
                     onTermination: (() -> Void)? = nil,
                     builder: @escaping (Continuation) -> Void) {
        self.bufferingPolicy = bufferingPolicy
        self.onTermination = onTermination
        self.builder = builder
    }

    func makeAsyncIterator() -> Iterator {
        var continuation: AsyncStream<Element>.Continuation?
        let stream = AsyncStream<Element> { innerContinuation in
            continuation = innerContinuation
            builder(innerContinuation)
        }

        return Iterator(iterator: stream.makeAsyncIterator()) {
            continuation?.finish()
            self.onTermination?()
        }
    }

    struct Iterator: AsyncIteratorProtocol {
        private final class Token { // swiftlint:disable:this nesting
            private let onDeinit: () -> Void

            init(onDeinit: @escaping () -> Void) {
                self.onDeinit = onDeinit
            }

            deinit {
                onDeinit()
            }
        }

        private var iterator: AsyncStream<Element>.AsyncIterator
        private let token: Token

        init(iterator: AsyncStream<Element>.AsyncIterator, onCancellation: @escaping () -> Void) {
            self.iterator = iterator
            token = Token(onDeinit: onCancellation)
        }

        mutating func next() async -> Element? {
            await iterator.next()
        }
    }
}

#endif
