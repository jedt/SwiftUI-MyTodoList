import Foundation
import GRDB
import os.log

/// A database of todo items.
///
/// You create an `AppDatabase` with a connection to an SQLite database
/// (see <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseconnections>).
///
/// Create those connections with a configuration returned from
/// `AppDatabase/makeConfiguration(_:)`.
///
/// For example:
///
/// ```swift
/// // Create an in-memory AppDatabase
/// let config = AppDatabase.makeConfiguration()
/// let dbQueue = try DatabaseQueue(configuration: config)
/// let appDatabase = try AppDatabase(dbQueue)
/// ```
struct AppDatabase {
    /// Creates an `AppDatabase`, and makes sure the database schema
    /// is ready.
    ///
    /// - important: Create the `DatabaseWriter` with a configuration
    ///   returned by ``makeConfiguration(_:)``.
    init(_ dbWriter: any DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }
    
    /// Provides access to the database.
    ///
    /// Application can use a `DatabasePool`, while SwiftUI previews and tests
    /// can use a fast in-memory `DatabaseQueue`.
    ///
    /// See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseconnections>
    private let dbWriter: any DatabaseWriter
}

// MARK: - Database Configuration

extension AppDatabase {
    private static let sqlLogger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "SQL")
    
    /// Returns a database configuration suited for `PlayerRepository`.
    ///
    /// SQL statements are logged if the `SQL_TRACE` environment variable
    /// is set.
    ///
    /// - parameter base: A base configuration.
    public static func makeConfiguration(_ base: Configuration = Configuration()) -> Configuration {
        var config = base
        
        // An opportunity to add required custom SQL functions or
        // collations, if needed:
        // config.prepareDatabase { db in
        //     db.add(function: ...)
        // }
        
        // Log SQL statements if the `SQL_TRACE` environment variable is set.
        // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/database/trace(options:_:)>
        if ProcessInfo.processInfo.environment["SQL_TRACE"] != nil {
            config.prepareDatabase { db in
                db.trace {
                    // It's ok to log statements publicly. Sensitive
                    // information (statement arguments) are not logged
                    // unless config.publicStatementArguments is set
                    // (see below).
                    os_log("%{public}@", log: sqlLogger, type: .debug, String(describing: $0))
                }
            }
        }
        
#if DEBUG
        // Protect sensitive information by enabling verbose debugging in
        // DEBUG builds only.
        // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/configuration/publicstatementarguments>
        config.publicStatementArguments = true
#endif
        
        return config
    }
}

// MARK: - Database Migrations

extension AppDatabase {
    /// The DatabaseMigrator that defines the database schema.
    ///
    /// See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/migrations>
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
#if DEBUG
        // Speed up development by nuking the database when migrations change
        // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/migrations>
        migrator.eraseDatabaseOnSchemaChange = true
#endif
        
        migrator.registerMigration("createPlayer") { db in
            // Create a table
            // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseschema>
            try db.create(table: "todoItem") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("title", .text).notNull()
                t.column("description", .text)
            }
        }
        
        // Migrations for future application versions will be inserted here:
        // migrator.registerMigration(...) { db in
        //     ...
        // }
        
        return migrator
    }
}

// MARK: - Database Access: Writes
// The write methods execute invariant-preserving database transactions.

extension AppDatabase {
    /// A validation error that prevents some players from being saved into
    /// the database.
    enum ValidationError: LocalizedError {
        case missingName
        
        var errorDescription: String? {
            switch self {
            case .missingName:
                return "Please provide a name"
            }
        }
    }
    
    /// Saves (inserts or updates) a player. When the method returns, the
    /// player is present in the database, and its id is not nil.
    //func savePlayer(_ player: inout Player) async throws {
    //    if player.name.isEmpty {
    //        throw ValidationError.missingName
    //    }
    //    player = try await dbWriter.write { [player] db in
    //        try player.saved(db)
    //    }
    //}
    
    /// Saves (inserts or updates) a todoItem. When the method returns, the
    /// player is present in the database, and its id is not nil.
    func saveTodoItem(_ todoItem: inout TodoItem) async throws {
        if todoItem.title.isEmpty {
            throw ValidationError.missingName
        }
        
        todoItem = try await dbWriter.write { [todoItem] db in
            try todoItem.saved(db)
        }
    }
    
    /// Delete the specified players
    //func deletePlayers(ids: [Int64]) async throws {
    //    try await dbWriter.write { db in
    //        _ = try Player.deleteAll(db, ids: ids)
    //    }
    //}
    
    func deleteTodoItem(_ todoItem: inout TodoItem) throws {
        try dbWriter.write { db in
            try todoItem.delete(db)
        }
    }
    
    /// Delete all players
    //func deleteAllPlayers() async throws {
    //    try await dbWriter.write { db in
    //        _ = try Player.deleteAll(db)
    //    }
    //}
    
    /// Refresh all players (by performing some random changes, for demo purpose).
    //func refreshPlayers() async throws {
    //    try await dbWriter.write { db in
    //        if try Player.all().isEmpty(db) {
    //            // When database is empty, insert new random players
    //            try createRandomPlayers(db)
    //        } else {
    //            // Insert a player
    //            if Bool.random() {
    //                _ = try Player.makeRandom().inserted(db) // insert but ignore inserted id
    //            }
    //
    //            // Delete a random player
    //            if Bool.random() {
    //                try Player.order(sql: "RANDOM()").limit(1).deleteAll(db)
    //            }
    //
    //            // Update some players
    //            for var player in try Player.fetchAll(db) where Bool.random() {
    //                try player.updateChanges(db) {
    //                    $0.score = Player.randomScore()
    //                }
    //            }
    //        }
    //    }
    //}
    
    func createTestDataForUITests() throws {
        try dbWriter.write { db in
            try AppDatabase.uiTestTodoItems.forEach { todoItem in
                _ = try todoItem.inserted(db) // insert but ignore inserted id
            }
        }
    }
    
    /// Create random players if the database is empty.
    func createRandomDataIfEmpty() throws {
        try dbWriter.write { db in
            if try TodoItem.all().isEmpty(db) {
                try createRandomTodoItems(db)
            }
        }
    }
    
    private static let uiTestTodoItems = [
        TodoItem(id: nil, title: "Arthur", description: nil),
        TodoItem(id: nil, title: "Barbara", description: nil),
        TodoItem(id: nil, title: "Craig", description: nil),
        TodoItem(id: nil, title: "David", description: nil),
        TodoItem(id: nil, title: "Elena", description: nil),
        TodoItem(id: nil, title: "Frederik", description: nil),
        TodoItem(id: nil, title: "Gilbert", description: nil),
        TodoItem(id: nil, title: "Henriette", description: nil)]
    
    func createPlayersForUITests() throws {
        try dbWriter.write { db in
            try AppDatabase.uiTestTodoItems.forEach { player in
                _ = try player.inserted(db) // insert but ignore inserted id
            }
        }
    }

    private func createRandomTodoItems(_ db: Database) throws {
        for _ in 0..<8 {
            _ = try TodoItem.makeRandom().inserted(db) // insert but ignore inserted id
        }
    }
}

// MARK: - Database Access: Reads

// This demo app does not provide any specific reading method, and instead
// gives an unrestricted read-only access to the rest of the application.
// In your app, you are free to choose another path, and define focused
// reading methods.
extension AppDatabase {
    /// Provides a read-only access to the database
    var reader: DatabaseReader {
        dbWriter
    }
}
