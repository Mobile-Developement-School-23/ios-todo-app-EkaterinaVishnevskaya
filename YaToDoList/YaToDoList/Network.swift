//
//  Network.swift
//  YaToDoList
//
//  Created by Екатерина Вишневская on 07.07.2023.
//

import Foundation

enum NetworkErrors: Error {
    case networkError
    case networkErrorWithCode(Int)
    case noData
}

extension URLSession {
    func fetch(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        var task: URLSessionDataTask?
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                task = self.dataTask(with: urlRequest) { (data, response, error) in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let response = response as? HTTPURLResponse else {
                        continuation.resume(throwing: NetworkErrors.networkError)
                        return
                    }
                    guard (200...299).contains(response.statusCode) else {
                        continuation.resume(throwing: NetworkErrors.networkErrorWithCode(response.statusCode))
                        return
                    }
                    if let data = data {
                        continuation.resume(returning: (data, response))
                    } else {
                        continuation.resume(throwing: NetworkErrors.noData)
                    }
                }
                task?.resume()
            }
        } onCancel: { [weak task] in
            task?.cancel()
        }
    }
}
