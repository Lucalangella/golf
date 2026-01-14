//
//  GolfImmersiveVIew.swift
//  Golf Vision
//
//  Created by Luca Langella 1 on 14/01/26.
//

import SwiftUI
import RealityKit
import RealityKitContent // If using packages

struct GolfImmersiveView: View {
    @Bindable var config: GolfConfig
    
    // We keep a reference to the loaded entity to update it
    @State private var clubEntity: Entity?

    var body: some View {
        RealityView { content in
            // 1. Create the Hand Anchor (Right Hand, Palm)
            let handAnchor = AnchorEntity(.hand(.right, location: .palm))
            
            // 2. Load your "Golf_club" model
            // Note: If "Golf_club" isn't found, this will fail silently.
            // Ensure the name matches your file exactly.
            if let club = try? await Entity(named: "Golf_club") {
                clubEntity = club
                
                // Add club as a child of the hand anchor
                handAnchor.addChild(club)
            } else {
                // Fallback: A red stick if model is missing
                let mesh = MeshResource.generateBox(size: [0.05, 1.0, 0.05])
                let material = SimpleMaterial(color: .red, isMetallic: false)
                let placeholder = ModelEntity(mesh: mesh, materials: [material])
                clubEntity = placeholder
                handAnchor.addChild(placeholder)
            }
            
            // 3. Add anchor to scene
            content.add(handAnchor)
            
        } update: { content in
            // 4. REAL-TIME UPDATES
            // Every time 'config' changes, this block runs
            if let club = clubEntity {
                club.position = config.positionVector
                club.orientation = config.rotationQuaternion
            }
        }
    }
}
