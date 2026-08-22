////
////  SyncEngine.swift
////  TaskManager
////
////  Created by Abhishek Kumar on 22/08/26.
////
//

import Foundation

actor SyncEngine: SyncEngineProtocol {
    
    private let syncRepo: SyncMutationRepositoryProtocol
    private let taskRepo: TaskRepositoryProtocol
    private let networkService: NetworkServiceProtocol
    private var isSyncing = false
    
    init(
        syncRepo: SyncMutationRepositoryProtocol,
        taskRepo: TaskRepositoryProtocol,
        networkService: NetworkServiceProtocol
    ) {
        self.syncRepo = syncRepo
        self.taskRepo = taskRepo
        self.networkService = networkService
    }
    
    func startSync() async {
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }
        
        await processOutbox()
    }
    
    private func processOutbox() async {
        do {
            let mutations = try await syncRepo.fetchPendingMutations()
            guard !mutations.isEmpty else { return }
            
            for mutation in mutations {
                let success = await processSingleMutation(mutation)
                if !success { break }
            }
        } catch {
            print("SyncEngine fetch failed: \(error)")
        }
    }
    
    private func processSingleMutation(_ mutation: SyncMutationItem) async -> Bool {
        let endpoint: Requestable
        
        switch mutation.mutationType {
        case "create":
            guard let payload = mutation.payload else { return false }
            endpoint = TaskRoute.Create(payload: payload)
        case "update":
            guard let payload = mutation.payload else { return false }
            endpoint = TaskRoute.Update(payload: payload, taskId: mutation.taskId)
        case "delete":
            endpoint = TaskRoute.Delete(taskId: mutation.taskId)
        default:
            return false
        }
        
        do {
            // 3. Execute Network Call
            try await networkService.execute(endpoint: endpoint)
            
            // 4. Update Task State
            let isDelete = (mutation.mutationType == "delete")
            try await taskRepo.markAsSynced(taskId: mutation.taskId, wasDeletedRemotely: isDelete)
            
            // 5. Clear from Outbox
            try await syncRepo.deleteMutation(id: mutation.id)
            
            return true
        } catch {
            return false
        }
    }
}
