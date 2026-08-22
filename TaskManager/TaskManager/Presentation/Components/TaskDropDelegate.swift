//
//  TaskDropDelegate.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct TaskDropDelegate: DropDelegate {
    let targetTask: TaskItem
    let viewModel: BoardViewModel
    
    func dropEntered(info: DropInfo) {
        guard let draggedId = viewModel.draggedTaskId else { return }
        viewModel.updateTaskOrder(draggedId: draggedId, target: targetTask)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggedId = viewModel.draggedTaskId else { return false }
        Task {
            await viewModel.finalizeDrop(draggedId: draggedId, on: targetTask)
        }
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
