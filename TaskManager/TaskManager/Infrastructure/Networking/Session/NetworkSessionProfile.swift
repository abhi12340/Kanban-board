//
//  NetworkSessionProfile.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import Foundation

nonisolated enum NetworkSessionProfile: Sendable {
    case defaultConfig
    case background(id: String)
    
    var configuration: URLSessionConfiguration {
        switch self {
        case .defaultConfig:
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 15
            return config
        case .background(let id):
            return URLSessionConfiguration.background(withIdentifier: id)
        }
    }
}
