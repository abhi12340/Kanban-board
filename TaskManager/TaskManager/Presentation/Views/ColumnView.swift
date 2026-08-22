//
//  ColumnView.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct ColumnView: View {
    let status: TaskStatus
    let tasks: [TaskItem]
    let viewModel: BoardViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(status.rawValue)
                .font(.title3.bold())
                .padding(.horizontal)
                .padding(.top)
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(tasks) { task in
                        TaskCardView(task: task, viewModel: viewModel)
                            .onDrop(of: [UTType.plainText.identifier], delegate: TaskDropDelegate(targetTask: task, viewModel: viewModel))
                    }
                    Color.clear
                        .frame(height: 100)
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
        .frame(width: 300)
        .onDrop(of: [UTType.plainText.identifier], delegate: ColumnDropDelegate(status: status, viewModel: viewModel))
    }
}
