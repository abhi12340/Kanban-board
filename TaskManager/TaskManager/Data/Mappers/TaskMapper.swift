//
//  TaskMapper.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import Foundation

extension TaskItem {
    func toDTO() -> TaskDTO {
        return TaskDTO(
            id: self.id,
            title: self.title,
            taskDescription: self.taskDescription,
            status: self.status.rawValue,
            sortOrder: self.sortOrder,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
