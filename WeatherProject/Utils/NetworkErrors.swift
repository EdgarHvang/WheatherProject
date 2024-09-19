//
//  NetworkErrors.swift
//  WeatherProject
//
//  Created by Qiyao Huang on 9/18/24.
//

import Foundation

enum NetWorkError: Error {
    case invalidURL
    case statusCodeError(HTTPCode)
    case parseJsonFailed
    case unexpectedResponse
}

extension NetWorkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case let .statusCodeError(statusCode): return "Unexpected HTTP status code: \(statusCode)"
        case .parseJsonFailed: return "Unexpected JSON parse error"
        case .unexpectedResponse: return "Unexpected response from the server"
        }
    }
}

typealias HTTPCode = Int

typealias HTTPCodes = Range<HTTPCode>
extension HTTPCodes {
    static let success = 200 ..< 300
}
