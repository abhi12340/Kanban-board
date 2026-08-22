//
//  CoreDataStack.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import CoreData
import Foundation

// MARK: - Protocol

public protocol CoreDataStackProtocol: Sendable {
    var viewContext: NSManagedObjectContext { get }
    func newBackgroundContext() -> NSManagedObjectContext
    func saveContext(_ context: NSManagedObjectContext) async throws
}

// MARK: - Concrete Implementation

public final class CoreDataStack: CoreDataStackProtocol {
    
    private let container: NSPersistentContainer
    
    /// Initializes the Core Data stack.
    public init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TaskManager")
        
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error loading Core Data: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    public var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    public func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.name = "BackgroundSyncContext"
        return context
    }
    
    public func saveContext(_ context: NSManagedObjectContext) async throws {
        try await context.perform {
            guard context.hasChanges else { return }
            try context.save()
        }
    }
}
