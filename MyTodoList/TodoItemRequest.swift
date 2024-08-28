import GRDB
import GRDBQuery

struct TodoItemRequest: ValueObservationQueryable {
    static var defaultValue: [TodoItem] { [ ] }
    
    func fetch(_ db: Database) throws -> [TodoItem] {
        return try TodoItem.all().fetchAll(db)
    }
}
