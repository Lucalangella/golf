import SwiftUI

@main
struct GolfApp: App {
    // Create the shared state
    @State private var config = GolfConfig()
    
    var body: some Scene {
        // 1. The 2D Window for Controls
        WindowGroup(id: "Controls") {
            GolfControlsView(config: config)
        }
        .windowStyle(.plain)

        // 2. The Immersive Space for the Golf Experience
        ImmersiveSpace(id: "GolfSpace") {
            GolfImmersiveView(config: config)
        }
    }
}
