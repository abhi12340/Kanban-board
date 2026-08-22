//
//  NetworkServiceProtocol.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import Foundation

protocol NetworkServiceProtocol: Sendable {
    func execute(endpoint: Requestable) async throws
}
