import SwiftUI

@main
struct PhotoBookApp: App {
    @StateObject private var photoManager = PhotoManager()
    @StateObject private var layoutEngine = LayoutEngine()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(photoManager)
                .environmentObject(layoutEngine)
        }
    }
}
