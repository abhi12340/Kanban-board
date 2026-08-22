//
//  TaskRepository.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import CoreData
import Foundation

final class TaskRepository: TaskRepositoryProtocol {
    
    private let coreDataStack: CoreDataStackProtocol
    private let syncRepo: SyncMutationRepositoryProtocol
    
    public init(coreDataStack: CoreDataStackProtocol, syncRepo: SyncMutationRepositoryProtocol) {
        self.coreDataStack = coreDataStack
        self.syncRepo = syncRepo
    }
    
    func fetchAllTasks() async throws -> [TaskItem] {
        let context = coreDataStack.viewContext
        
        return try await context.perform {
            let request = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
            request.predicate = NSPredicate(format: "taskIsDeleted == %d", false)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.sortOrder, ascending: true)]
            
            let entities = try context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }
    
    func createTask(_ task: TaskItem) async throws {
        let context = coreDataStack.newBackgroundContext()
        
        // 1. Map Domain Entity to Core Data Entity
        let entity = TaskEntity(context: context)
        entity.id = task.id
        entity.title = task.title
        entity.taskDescription = task.taskDescription
        entity.status = task.status.rawValue
        entity.sortOrder = task.sortOrder
        entity.createdAt = task.createdAt
        entity.updatedAt = task.updatedAt
        entity.syncState = SyncState.pendingSync.rawValue
        entity.taskIsDeleted = false
        
        let mutation = SyncMutationEntity(context: context)
        mutation.id = UUID()
        mutation.taskId = task.id
        mutation.mutationType = "create"
        mutation.createdAt = Date()
        let dto = task.toDTO()
        if let payloadData = try? JSONEncoder().encode(dto) {
            mutation.payload = payloadData
        }
        
        try await coreDataStack.saveContext(context)
    }
    
    func updateTask(_ task: TaskItem) async throws {
        let context = coreDataStack.newBackgroundContext()
        
        try await context.perform {
            let request = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
            request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            request.fetchLimit = 1
            
            guard let entity = try context.fetch(request).first else {
                throw NSError(domain: "TaskRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Task not found"])
            }
            
            // 1. Update local entity
            entity.title = task.title
            entity.taskDescription = task.taskDescription
            entity.status = task.status.rawValue
            entity.sortOrder = task.sortOrder
            entity.updatedAt = Date()
            entity.syncState = SyncState.pendingSync.rawValue
            
            try self.syncRepo.queueMutation(for: task, type: "update", in: context)
            
            // 3. Save
            try context.save()
        }
    }
    
    func deleteTask(id: UUID) async throws {
        let context = coreDataStack.newBackgroundContext()
        
        try await context.perform {
            let request = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            
            guard let entity = try context.fetch(request).first else { return }
            
            // 1. Soft delete: hide it from the UI immediately
            entity.taskIsDeleted = true
            entity.syncState = SyncState.pendingSync.rawValue
            
            try self.syncRepo.prepareDeletionMutations(for: id, in: context)
            
            try context.save()
        }
    }
    
    func markAsSynced(taskId: UUID, wasDeletedRemotely: Bool) async throws {
        let context = coreDataStack.newBackgroundContext()
        
        try await context.perform {
            let request = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
            request.predicate = NSPredicate(format: "id == %@", taskId as CVarArg)
            request.fetchLimit = 1
            
            if let entity = try context.fetch(request).first {
                if wasDeletedRemotely {
                    context.delete(entity)
                } else {
                    entity.syncState = SyncState.synced.rawValue
                }
                try context.save()
            }
        }
    }
    
    func reorderTask(taskId: UUID, to newStatus: TaskStatus, after previousTask: TaskItem?, before nextTask: TaskItem?) async throws {
        // 1. Calculate the new Double index
        let newSortOrder: Double
        if let previous = previousTask, let next = nextTask {
            newSortOrder = (previous.sortOrder + next.sortOrder) / 2.0
        } else if let previous = previousTask {
            newSortOrder = previous.sortOrder + 1000.0
        } else if let next = nextTask {
            newSortOrder = next.sortOrder / 2.0
        } else {
            newSortOrder = 1000.0
        }
        
        // 2. Fetch all tasks
        let allTasks = try await fetchAllTasks()
        guard var taskToMove = allTasks.first(where: { $0.id == taskId }) else {
            throw NSError(domain: "TaskRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Task not found"])
        }
        
        // 3. Update the pure domain model
        taskToMove.sortOrder = newSortOrder
        taskToMove.status = newStatus
        
        // 4. update core data
        try await updateTask(taskToMove)
    }
    
}
