//
//  Requestable.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import Foundation

protocol Requestable: Sendable {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
    var sessionProfile: NetworkSessionProfile { get }
    func buildURLRequest(baseURL: String) -> URLRequest?
}

extension Requestable {
    var headers: [String: String]? { nil }
    var body: Data? { nil }
    var sessionProfile: NetworkSessionProfile { .defaultConfig }
    
    func buildURLRequest(baseURL: String) -> URLRequest? {
        guard let url = URL(string: baseURL + path) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
}
