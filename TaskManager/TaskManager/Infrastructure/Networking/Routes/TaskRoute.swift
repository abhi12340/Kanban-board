//
//  TaskRoute.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import Foundation

enum TaskRoute {
    
    nonisolated struct Create: Requestable {
        let path = "/tasks"
        let method: HTTPMethod = .post
        let body: Data?
        
        init(payload: Data) {
            self.body = payload
        }
    }
    
    nonisolated struct Update: Requestable {
        let path: String
        let method: HTTPMethod = .put
        let body: Data?
        
        init(payload: Data, taskId: UUID) {
            self.path = "/tasks/\(taskId.uuidString)"
            self.body = payload
        }
    }
    
    nonisolated struct Delete: Requestable {
        let path: String
        let method: HTTPMethod = .delete
        let body: Data? = nil
        
        init(taskId: UUID) {
            self.path = "/tasks/\(taskId.uuidString)"
        }
    }
}
