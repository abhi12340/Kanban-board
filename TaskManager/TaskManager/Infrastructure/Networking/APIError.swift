//
//  APIError.swift
//  StockPulse
//
//  Created by Abhishek Kumar on 01/08/26.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case serverError(statusCode: Int)
    case decodingError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The endpoint URL is invalid."
        case .serverError(let code): return "Server responded with HTTP status code \(code)."
        case .decodingError(let err): return "Failed to decode response: \(err.localizedDescription)"
        case .unknown(let err): return "Network error: \(err.localizedDescription)"
        }
    }
}
