//
//  Golf_VisionApp.swift
//  Golf Vision
//
//  Created by Luca Langella 1 on 08/01/26.
//

import SwiftUI

@main
struct Golf_VisionApp: App {
    var body: some Scene {
        // We use an ImmersiveSpace for AR hand tracking
        ImmersiveSpace(id: "LiveDebugger") {
            LiveGripDebugger()
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
        // A simple launcher window is required by visionOS
        WindowGroup {
            VStack {
                Text("Golf Vision Debugger")
                OpenImmersiveSpaceButton()
            }
        }
    }
}

struct OpenImmersiveSpaceButton: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    var body: some View {
        Button("Start Live Debugging") {
            Task { await openImmersiveSpace(id: "LiveDebugger") }
        }
    }
}
