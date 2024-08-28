//
//  ItemNew.swift
//  MyTodoList
//
//  Created by Jed Tiotuico on 8/26/24.
//

import SwiftUI

struct ItemNew: View {
    // For write access to the database we
    // the Environment wrapper enables you to
    // access the databse from this view
    @Environment(\.appDatabase) var appDatabase
    @State private var title: String = ""
    @State private var description: String = ""
    
    // Initialize a property that will store
    // existing TodoItem for editing
    var todoItem: TodoItem?
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Title")
                TextField("Enter the title", text: $title)
            }
            VStack(alignment: .leading) {
                Text("Description")
                TextField("Enter the description", text: $description)
            }
            Spacer()
            Button(action: {
                // saveTodoItem
                Task {
                    if var existingItem = todoItem {
                        existingItem.title = title
                        existingItem.description = description
                        // try appDatabase
                        try await appDatabase.saveTodoItem(&existingItem)
                    } else {
                        var todoItem = TodoItem(title: title, description: description)
                        try await appDatabase.saveTodoItem(&todoItem)
                    }
                }
            }, label: {
                Text(todoItem == nil ? "Save New" : "Save Changes")
            })
        }
        .padding()
        .navigationTitle(todoItem == nil ? "New Todo Item" : "Edit Todo Item")
        .onAppear {
            // Update the state variables when the view appears
            if let todoItem = todoItem {
                title = todoItem.title
                description = todoItem.description ?? ""
            }
        }
    }
}

struct TodoItemForm {
    var title: String
    var description: String
}

extension TodoItemForm {
    init(_ todoItem: TodoItem) {
        self.title = todoItem.title
        self.description = todoItem.description ?? ""
    }
}


#Preview {
    ItemNew(todoItem: TodoItem(title: "Sample Title", description: "Sample Description"))
}
