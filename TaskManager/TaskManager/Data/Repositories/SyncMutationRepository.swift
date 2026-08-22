//
//  SyncMutationRepository.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import Foundation
import CoreData

final class SyncMutationRepository: SyncMutationRepositoryProtocol {
    
    private let coreDataStack: CoreDataStackProtocol
    
    init(coreDataStack: CoreDataStackProtocol) {
        self.coreDataStack = coreDataStack
    }
    
    func fetchPendingMutations() async throws -> [SyncMutationItem] {
        let context = coreDataStack.newBackgroundContext()
        
        return try await context.perform {
            let request = NSFetchRequest<SyncMutationEntity>(entityName: "SyncMutationEntity")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \SyncMutationEntity.createdAt, ascending: true)]
            request.fetchLimit = 50
            let entities = try context.fetch(request)
            
            return entities.compactMap { entity in
                guard let id = entity.id,
                      let taskId = entity.taskId,
                      let type = entity.mutationType,
                      let createdAt = entity.createdAt else { return nil }
                
                return SyncMutationItem(
                    id: id,
                    taskId: taskId,
                    mutationType: type,
                    payload: entity.payload,
                    createdAt: createdAt
                )
            }
        }
    }
    
    func deleteMutation(id: UUID) async throws {
        let context = coreDataStack.newBackgroundContext()
        
        try await context.perform {
            let request = NSFetchRequest<SyncMutationEntity>(entityName: "SyncMutationEntity")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                try context.save()
            }
        }
    }
    
    func queueMutation(for task: TaskItem, type: String, in context: NSManagedObjectContext) throws {
        if type == "update" {
            let request = NSFetchRequest<SyncMutationEntity>(entityName: "SyncMutationEntity")
            request.predicate = NSPredicate(format: "taskId == %@ AND mutationType == 'update'", task.id as CVarArg)
            request.fetchLimit = 1
            
            if let existing = try context.fetch(request).first {
                existing.payload = try JSONEncoder().encode(task)
                return
            }
        }
        
        let newMutation = SyncMutationEntity(context: context)
        newMutation.id = UUID()
        newMutation.taskId = task.id
        newMutation.mutationType = type
        newMutation.payload = try JSONEncoder().encode(task)
        newMutation.createdAt = Date()
    }
    
    func prepareDeletionMutations(for taskId: UUID, in context: NSManagedObjectContext) throws {
        let req = NSFetchRequest<SyncMutationEntity>(entityName: "SyncMutationEntity")
        req.predicate = NSPredicate(format: "taskId == %@", taskId as CVarArg)
        
        let pending = try context.fetch(req)
        let serverIsUnaware = pending.contains { $0.mutationType == "create" }
        
        for mutation in pending { context.delete(mutation) }
        
        if !serverIsUnaware {
            let delMutation = SyncMutationEntity(context: context)
            delMutation.id = UUID()
            delMutation.taskId = taskId
            delMutation.mutationType = "delete"
            delMutation.createdAt = Date()
        }
    }
}
