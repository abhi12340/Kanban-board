//
//  BoardViewModel.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class BoardViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    var draggedTaskId: UUID?
    private let taskRepo: TaskRepositoryProtocol
    private let syncEngine: SyncEngineProtocol
    
    init(taskRepo: TaskRepositoryProtocol, syncEngine: SyncEngineProtocol) {
        self.taskRepo = taskRepo
        self.syncEngine = syncEngine
    }
    
    func fetchTasks() async {
        do {
            tasks = try await taskRepo.fetchAllTasks()
        } catch {
            print("Fetch failed: \(error)")
        }
    }
    
    func tasks(for status: TaskStatus) -> [TaskItem] {
        tasks.filter { $0.status == status }
             .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    func updateTaskOrder(draggedId: UUID, target: TaskItem) {
        guard draggedId != target.id else { return }
        guard let fromIndex = tasks.firstIndex(where: { $0.id == draggedId }),
              let toIndex = tasks.firstIndex(where: { $0.id == target.id }) else { return }
        
        let draggedTask = tasks[fromIndex]
        
        guard draggedTask.status == target.status else { return }
        
        withAnimation(.default) {
            let tempOrder = tasks[fromIndex].sortOrder
            tasks[fromIndex].sortOrder = tasks[toIndex].sortOrder
            tasks[toIndex].sortOrder = tempOrder
        }
    }
    
    func finalizeDrop(draggedId: UUID, on targetTask: TaskItem) async {
        guard let fromIndex = tasks.firstIndex(where: { $0.id == draggedId }) else { return }
        
        withAnimation {
            tasks[fromIndex].status = targetTask.status
            tasks[fromIndex].sortOrder = targetTask.sortOrder + 0.001
        }
        await persistReorder(draggedId: draggedId)
    }
    
    func finalizeDrop(draggedId: UUID, in status: TaskStatus) async {
        guard let fromIndex = tasks.firstIndex(where: { $0.id == draggedId }) else { return }
        
        withAnimation {
            tasks[fromIndex].status = status
            
            // Calculate the bottom of the new column
            let maxOrder = tasks.filter { $0.status == status }.map(\.sortOrder).max() ?? 0.0
            tasks[fromIndex].sortOrder = maxOrder + 1000.0
        }
        
        await persistReorder(draggedId: draggedId)
    }
    
    private func persistReorder(draggedId: UUID) async {
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        guard let currentIndex = tasks.firstIndex(where: { $0.id == draggedId }) else { return }
        let dragged = tasks[currentIndex]
        
        let columnTasks = tasks(for: dragged.status)
        let localIndex = columnTasks.firstIndex(where: { $0.id == dragged.id }) ?? 0
        
        let previousTask = localIndex > 0 ? columnTasks[localIndex - 1] : nil
        let nextTask = localIndex < columnTasks.count - 1 ? columnTasks[localIndex + 1] : nil
        
        do {
            try await taskRepo.reorderTask(taskId: dragged.id, to: dragged.status, after: previousTask, before: nextTask)
            await syncEngine.startSync()
        } catch {
            showError(message: "Failed to save task position.")
            await fetchTasks()
        }
        self.draggedTaskId = nil
    }
    
    func createNewTask(title: String, description: String) async {
        let todoTasks = tasks.filter { $0.status == .todo }
        let maxSortOrder = todoTasks.map(\.sortOrder).max() ?? 0.0
        
        let newSortOrder = maxSortOrder + 1000.0
        
        let newTask = TaskItem(
            id: UUID(),
            title: title,
            taskDescription: description,
            status: .todo,
            sortOrder: newSortOrder,
            createdAt: Date(),
            updatedAt: Date(),
            syncState: .pendingSync
        )
        
        do {
            try await taskRepo.createTask(newTask)
            
            await fetchTasks()
            await syncEngine.startSync()
        } catch {
            print("Failed to create task: \(error.localizedDescription)")
        }
    }
    
    func deleteTask(taskId: UUID) async {
        // 1. Optimistic UI: Instantly remove it from the screen
        withAnimation {
            tasks.removeAll { $0.id == taskId }
        }
        
        // 2. Background Database & Network Update
        do {
            try await taskRepo.deleteTask(id: taskId)
            await syncEngine.startSync()
        } catch {
            // Revert UI if the database fails
            showError(message: "Failed to delete the task.")
            await fetchTasks()
        }
    }
    
    private func showError(message: String) {
        self.errorMessage = message
        self.showErrorAlert = true
    }
}
