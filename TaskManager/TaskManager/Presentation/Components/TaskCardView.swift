//
//  TaskCardView.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct TaskCardView: View {
    let task: TaskItem
    let viewModel: BoardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // 1. Top Row: Title and Menu Button
            HStack(alignment: .top) {
                Text(task.title)
                    .font(.headline)
                
                Spacer()
                Menu {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.deleteTask(taskId: task.id)
                        }
                    } label: {
                        Label("Delete Task", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                        .frame(width: 30, height: 30, alignment: .topTrailing)
                        .contentShape(Rectangle())
                }
            }
            if !task.taskDescription.isEmpty {
                Text(task.taskDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            HStack {
                Spacer()
                if task.syncState == .pendingSync {
                    Image(systemName: "cloud.fill")
                        .foregroundColor(.gray.opacity(0.5))
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onDrag {
            viewModel.draggedTaskId = task.id
            return NSItemProvider(object: task.id.uuidString as NSString)
        }
    }
}
