//
//  NetworkService.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import Foundation

final class NetworkService: NetworkServiceProtocol {
    
    private let sessionFactory: NetworkSessionFactoryProtocol
    private let baseURL: String
    
    init(sessionFactory: NetworkSessionFactoryProtocol, baseURL: String) {
        self.sessionFactory = sessionFactory
        self.baseURL = baseURL
    }
    
    func execute(endpoint: Requestable) async throws {
        guard let request = endpoint.buildURLRequest(baseURL: baseURL) else {
            throw APIError.invalidURL
        }
        
        let activeSession = await sessionFactory.session(for: endpoint.sessionProfile)
        
        let (_, response) = try await activeSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidURL
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
    }
}
