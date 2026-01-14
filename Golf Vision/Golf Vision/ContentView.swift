//
//  ContentView.swift
//  Golf Vision
//
//  Created by Luca Langella 1 on 08/01/26.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

struct ContentView: View {
    
    @State private var golfClubEntity: Entity?
    
    var body: some View {
        RealityView { content in
            // Load and add the golf club model from the bundle
            if let modelEntity = try? await Entity.load(named: "Golf_club2") {
                modelEntity.name = "GolfClub"
                
                // Adjust scale if needed (you can modify this)
                modelEntity.scale = [1, 1, 1]
                
                // Store reference to update later
                golfClubEntity = modelEntity
                content.add(modelEntity)
            }
        }
        .task {
            await runHandTracking()
        }
    }
    
    func runHandTracking() async {
        let session = ARKitSession()
        let handTracking = HandTrackingProvider()
        
        guard HandTrackingProvider.isSupported else {
            print("Hand tracking is not supported on this device")
            return
        }
        
        do {
            try await session.run([handTracking])
            
            for await update in handTracking.anchorUpdates {
                let handAnchor = update.anchor
                
                // Only track the right hand
                guard handAnchor.chirality == .right else { continue }
                
                // Update golf club position and orientation
                if let golfClub = golfClubEntity {
                    if let skeleton = handAnchor.handSkeleton {
                        // Get relevant hand joints for natural grip
                        let wristJoint = skeleton.joint(.wrist)
                        let middleFingerKnuckle = skeleton.joint(.middleFingerKnuckle)
                        
                        // Use point between wrist and knuckles for more natural grip position
                        let wristTransform = handAnchor.originFromAnchorTransform * wristJoint.anchorFromJointTransform
                        let knuckleTransform = handAnchor.originFromAnchorTransform * middleFingerKnuckle.anchorFromJointTransform
                        
                        // Extract positions
                        let wristPos = SIMD3<Float>(wristTransform.columns.3.x, wristTransform.columns.3.y, wristTransform.columns.3.z)
                        let knucklePos = SIMD3<Float>(knuckleTransform.columns.3.x, knuckleTransform.columns.3.y, knuckleTransform.columns.3.z)
                        
                        // Position in the palm (60% toward knuckles from wrist)
                        let gripPosition = wristPos + (knucklePos - wristPos) * 0.6
                        
                        // Set the club position
                        golfClub.position = gripPosition
                        
                        // Set orientation based on hand
                        golfClub.transform.rotation = Transform(matrix: wristTransform).rotation
                        
                        // Natural golf grip rotation adjustments
                        // Rotate so shaft runs along palm and club head points down
                        let pitchRotation = simd_quatf(angle: .pi / 6, axis: [1, 0, 0])  // Tilt forward slightly
                        let rollRotation = simd_quatf(angle: -.pi / 2, axis: [0, 0, 1])  // Rotate to align with palm
                        let yawRotation = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])    // Point club head down
                        
                        golfClub.orientation = golfClub.orientation * yawRotation * rollRotation * pitchRotation
                        
                        // Fine-tune position offset for better grip feel
                        // Adjust these values if needed
                        let forwardOffset = SIMD3<Float>(0, -0.05, 0.02)  // Slightly down and forward
                        golfClub.position += forwardOffset
                    }
                }
            }
        } catch {
            print("Failed to run ARKit session: \(error)")
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
