//
//  TaskEntity+CoreDataProperties.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//
//

public import Foundation
public import CoreData


public typealias TaskEntityCoreDataPropertiesSet = NSSet

extension TaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var sortOrder: Double
    @NSManaged public var status: String?
    @NSManaged public var syncState: String?
    @NSManaged public var taskDescription: String?
    @NSManaged public var taskIsDeleted: Bool
    @NSManaged public var title: String?
    @NSManaged public var updatedAt: Date?

}

extension TaskEntity : Identifiable {

}

extension TaskEntity {
    func toDomain() -> TaskItem {
        return TaskItem(
            id: self.id ?? UUID(),
            title: self.title ?? "Untitled",
            taskDescription: self.taskDescription ?? "",
            status: TaskStatus(rawValue: self.status ?? "To Do") ?? .todo,
            sortOrder: self.sortOrder,
            createdAt: self.createdAt ?? Date(),
            updatedAt: self.updatedAt ?? Date(),
            syncState: SyncState(rawValue: self.syncState ?? "synced") ?? .synced
        )
    }
}
