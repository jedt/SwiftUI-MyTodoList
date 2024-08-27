//
//  TodoItem.swift
//  MyTodoList
//
//  Created by Jed Tiotuico on 8/27/24.
//

import GRDB

struct TodoItem: Identifiable, Equatable {
    var id: Int64?
    var title: String
    var description: String?
}

extension TodoItem {
    static func new() -> TodoItem {
        TodoItem(id: nil, title: "", description: "")
    }
    
    /// Creates a new player with random name and random score
    static func makeRandom() -> TodoItem {
        TodoItem(id: nil, title: randomTitle(), description: "")
    }
    
    static func randomTitle() -> String {
        ["One", "Two", "Three", "Four", "Five"].randomElement()!
    }
}

extension TodoItem: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    fileprivate enum Columns {
        static let title = Column(CodingKeys.title)
        static let description = Column(CodingKeys.description)
    }
    
    /// Updates a todo item id after it has been inserted in the database.
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

extension DerivableRequest<TodoItem> {
    
}
