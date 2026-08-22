//
//  SyncMutationRepositoryProtocol.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import CoreData

protocol SyncMutationRepositoryProtocol: Sendable {
    func fetchPendingMutations() async throws -> [SyncMutationItem]
    func deleteMutation(id: UUID) async throws
    func queueMutation(for task: TaskItem, type: String, in context: NSManagedObjectContext) throws
    func prepareDeletionMutations(for taskId: UUID, in context: NSManagedObjectContext) throws
}
