//
//  SyncEngineProtocol.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import Foundation

protocol SyncEngineProtocol: Sendable {
    func startSync() async
}
