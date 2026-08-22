//
//  NetworkMonitor.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import Foundation
import Network

public final class NetworkMonitor: NetworkMonitorProtocol, @unchecked Sendable {
    
    private let monitor: NWPathMonitor
    private let monitorQueue = DispatchQueue(label: "com.taskboard.NetworkMonitorQueue")
    
    public var statusStream: AsyncStream<NetworkStatus> {
        AsyncStream { continuation in
            monitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    continuation.yield(.online)
                } else {
                    continuation.yield(.offline)
                }
            }
            
            // Start
            monitor.start(queue: monitorQueue)
            
            // Stop
            continuation.onTermination = { [weak self] _ in
                self?.monitor.cancel()
            }
        }
    }
    
    public init() {
        self.monitor = NWPathMonitor()
    }
}
