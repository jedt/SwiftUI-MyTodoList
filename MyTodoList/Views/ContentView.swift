//
//  ContentView.swift
//  MyTodoList
//
//  Created by Jed Tiotuico on 8/26/24.
//

import SwiftUI

struct ContentView: View {
    @State private var detailText: String = "select an option"
    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading) {
                Text("Main menu")
                    .font(.title)
                
                Button(action: {
                    detailText = "ItemNew"
                }, label: {
                    Text("Add Item")
                })
                
                Spacer()
            }
            .padding()
        
        } detail: {
            if detailText == "ItemNew" {
                ItemNew()
            }
            else {
                Text(detailText)
            }
        }
    }
}

#Preview {
    ContentView()
}
