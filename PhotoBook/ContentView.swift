import SwiftUI
import PhotosUI

struct ContentView: View {
    @EnvironmentObject var photoManager: PhotoManager
    @EnvironmentObject var layoutEngine: LayoutEngine
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            PhotoSelectionView()
                .tabItem {
                    Label("Select Photos", systemImage: "photo.on.rectangle")
                }
                .tag(0)

            LayoutPreviewView()
                .tabItem {
                    Label("Preview", systemImage: "book.closed")
                }
                .tag(1)

            PrintOptionsView()
                .tabItem {
                    Label("Print", systemImage: "printer")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PhotoManager())
        .environmentObject(LayoutEngine())
}
