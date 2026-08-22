//
//  BoardView.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import SwiftUI

struct BoardView: View {
    @StateObject var viewModel: BoardViewModel
    
    @State private var showingCreateTaskSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 20) {
                    
                    ForEach(TaskStatus.allCases, id: \.self) { status in
                        ColumnView(
                            status: status,
                            tasks: viewModel.tasks(for: status),
                            viewModel: viewModel
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Task Board")
            .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
            .task {
                await viewModel.fetchTasks()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreateTaskSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateTaskSheet) {
                CreateTaskView { title, description in
                    Task {
                        await viewModel.createNewTask(title: title, description: description)
                    }
                }
            }
            .alert("Something went wrong", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            
        }
    }
}
