//
//  ItemNew.swift
//  MyTodoList
//
//  Created by Jed Tiotuico on 8/26/24.
//

import SwiftUI

struct ItemNew: View {
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
                TextField("Enter the description", text: $title)
            }
            Spacer()
            Button(action: {
                print("save new")
            }, label: {
                Text("Save New")
            })
        }
        .padding()
    }
}

#Preview {
    ItemNew()
}
