import SwiftUI

struct ItemDetail: View {
    let todoItem: TodoItem

    var body: some View {
        VStack(alignment: .leading) {
            Text("Title")
                .font(.headline)
            Text(todoItem.title)
                .font(.title2)
                .padding(.bottom)

            if let description = todoItem.description {
                Text("Description")
                    .font(.headline)
                Text(description)
                    .padding(.bottom)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Todo Item Details")
    }
}

#Preview {
    ItemDetail(todoItem: TodoItem(title: "Sample Title", description: "Sample Description"))
}
