import SwiftUI

@main
struct GolfApp: App {
    var body: some Scene {
        // 1. The Immersive Space is now the main focus
        ImmersiveSpace(id: "GolfSpace") {
            GolfImmersiveView()
        }
        
        // 2. A simple entry window (optional, but good practice)
        WindowGroup {
            StartView()
        }
        .windowStyle(.plain)
        .defaultSize(width: 300, height: 200)
    }
}

// A simple button to start the experience
struct StartView: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow

    var body: some View {
        Button("Enter Golf Course") {
            Task {
                await openImmersiveSpace(id: "GolfSpace")
                dismissWindow() // Close this small menu
            }
        }
        .padding()
        .font(.title)
    }
}
