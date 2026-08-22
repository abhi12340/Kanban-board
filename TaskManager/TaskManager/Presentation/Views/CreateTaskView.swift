//
//  CreateTaskView.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import SwiftUI

struct CreateTaskView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var taskDescription: String = ""
    
    let onSave: (String, String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task Title", text: $title)
                    
                    TextEditor(text: $taskDescription)
                        .frame(minHeight: 100)
                        .overlay(

                            Text(taskDescription.isEmpty ? "Description (Optional)" : "")
                                .foregroundColor(Color(UIColor.placeholderText))
                                .padding(.horizontal, 4)
                                .padding(.top, 8)
                                .allowsHitTesting(false)
                            , alignment: .topLeading
                        )
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(title, taskDescription)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
