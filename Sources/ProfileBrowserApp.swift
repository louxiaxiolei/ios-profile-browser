import SwiftUI

@main
struct ProfileBrowserApp: App {
    @StateObject private var store = ProfileStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
