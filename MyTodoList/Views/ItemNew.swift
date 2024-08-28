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
                    var todoItem = TodoItem(title: title, description: description)
                    
                    try appDatabase.saveTodoItem(&todoItem)
                }
            }, label: {
                Text("Save New")
            })
        }
        .padding()
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
    ItemNew()
}
