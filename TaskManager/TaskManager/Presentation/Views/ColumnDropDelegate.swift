//
//  ColumnDropDelegate.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 23/08/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct ColumnDropDelegate: DropDelegate {
    let status: TaskStatus
    let viewModel: BoardViewModel
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggedId = viewModel.draggedTaskId else { return false }
        Task {
            await viewModel.finalizeDrop(draggedId: draggedId, in: status)
        }
        return true
    }
}
