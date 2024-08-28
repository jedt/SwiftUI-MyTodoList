//
//  ContentView.swift
//  MyTodoList
//
//  Created by Jed Tiotuico on 8/26/24.
//

import GRDBQuery
import SwiftUI

struct ContentView: View {
    @Environment(\.appDatabase) var appDatabase
    
    // Query is a property wrapper that subscribes to a ValueObservationQueryable type
    // where the value of the property becomes the result of the query
    @Query(TodoItemRequest()) private var todoItems: [TodoItem]
    
    @State private var detailText: String = "select an option"
    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading) {
                Text("Main menu")
                    .font(.title)
                
                Button(action: {
                    detailText = "ItemNew"
                }, label: {
                    Text("Todo Items")
                })
                
                Spacer()
            }
            .padding()
        } content: {
            // List View that stretch width
            VStack(alignment: .leading) {
                List(todoItems) { todoItem in
                    Text(todoItem.title)
                }
            }
        } detail: {
            // Detail View that stretch width
            VStack(alignment: .leading) {
                ItemNew()
            }
        }
    }
}

#Preview("Empty") {
    ContentView()
}

#Preview("Populated") {
    ContentView().appDatabase(.random())
}
