//
//  SyncMutationItem.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import Foundation

struct SyncMutationItem: Identifiable, Sendable {
    public let id: UUID
    public let taskId: UUID
    public let mutationType: String // "create", "update", "delete"
    public let payload: Data?
    public let createdAt: Date
}
