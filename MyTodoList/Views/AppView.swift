import GRDBQuery
import SwiftUI


/// the main application view
struct AppView: View {
    /// write access to the database
    @Environment(\.appDatabase) private var appDatabase
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    AppView()
}
