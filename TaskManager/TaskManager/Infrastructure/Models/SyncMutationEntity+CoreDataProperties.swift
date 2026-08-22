//
//  SyncMutationEntity+CoreDataProperties.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//
//

public import Foundation
public import CoreData


public typealias SyncMutationEntityCoreDataPropertiesSet = NSSet

extension SyncMutationEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SyncMutationEntity> {
        return NSFetchRequest<SyncMutationEntity>(entityName: "SyncMutationEntity")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var mutationType: String?
    @NSManaged public var payload: Data?
    @NSManaged public var taskId: UUID?

}

extension SyncMutationEntity : Identifiable {

}
