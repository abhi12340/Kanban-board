//
//  NetworkMonitorProtocol.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import Foundation

public enum NetworkStatus: Sendable {
    case online
    case offline
}

public protocol NetworkMonitorProtocol: Sendable {
    var statusStream: AsyncStream<NetworkStatus> { get }
}
