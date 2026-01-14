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
        WindowGroup {
            StartView()
        }
        
        ImmersiveSpace(id: "GolfSpace") {
            ContentView()
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}

struct StartView: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @State private var showImmersiveSpace = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Golf Vision")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Track your golf swing in AR")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button {
                Task {
                    if showImmersiveSpace {
                        await dismissImmersiveSpace()
                        showImmersiveSpace = false
                    } else {
                        await openImmersiveSpace(id: "GolfSpace")
                        showImmersiveSpace = true
                    }
                }
            } label: {
                Label(
                    showImmersiveSpace ? "Hide Golf Club" : "Show Golf Club",
                    systemImage: showImmersiveSpace ? "hand.raised.slash" : "hand.raised"
                )
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
    }
}
