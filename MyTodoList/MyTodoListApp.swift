import GRDBQuery
import SwiftUI

@main
struct MyTodoListApp: App {
    var body: some Scene {
        WindowGroup {
            // Persistence.swift
            // static let shared = makeShared()
            // makeShared() returns AppDatabase
            ContentView().appDatabase(.shared)
        }
    }
}

private struct AppDatabaseKey: EnvironmentKey {
    static var defaultValue: AppDatabase { .empty() }
}

extension EnvironmentValues {
    var appDatabase: AppDatabase {
        get { self[AppDatabaseKey.self] }
        set { self[AppDatabaseKey.self] = newValue }
    }
}

// View class extension
extension View {
    func appDatabase(_ appDatabase: AppDatabase) -> some View {
        self
            .environment(\.appDatabase, appDatabase)
            .databaseContext(.readOnly { appDatabase.reader })
    }
}
