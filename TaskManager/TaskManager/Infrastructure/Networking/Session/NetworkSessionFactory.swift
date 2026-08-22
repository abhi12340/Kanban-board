//
//  NetworkSessionFactory.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import Foundation

protocol NetworkSessionFactoryProtocol: Sendable {
    func session(for profile: NetworkSessionProfile) async -> URLSession
}

actor NetworkSessionFactory: NetworkSessionFactoryProtocol {
    private var sessions: [String: URLSession] = [:]
    
    init() {}
    
    func session(for profile: NetworkSessionProfile) -> URLSession {
        let key: String
        switch profile {
        case .background(let id): key = "background_\(id)"
        case .defaultConfig: key = "default"
        }
        
        if let existingSession = sessions[key] {
            return existingSession
        }
        
        let newSession = URLSession(configuration: profile.configuration)
        sessions[key] = newSession
        return newSession
    }
}
