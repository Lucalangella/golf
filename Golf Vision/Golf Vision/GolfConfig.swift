//
//  GolfConfig.swift
//  Golf Vision
//
//  Created by Luca Langella 1 on 14/01/26.
//

import SwiftUI
import RealityKit

@Observable
class GolfConfig {
    // Position offsets (in meters)
    var posX: Float = 0.0
    var posY: Float = 0.0
    var posZ: Float = 0.0
    
    // Rotation offsets (in degrees)
    var rotX: Float = 0.0
    var rotY: Float = 0.0
    var rotZ: Float = 0.0
    
    // Helper to get Position as SIMD3
    var positionVector: SIMD3<Float> {
        SIMD3(posX, posY, posZ)
    }
    
    // Helper to get Rotation as Quaternion
    var rotationQuaternion: simd_quatf {
        // Convert degrees to radians
        let angles = SIMD3<Float>(
            Float(rotX) * .pi / 180,
            Float(rotY) * .pi / 180,
            Float(rotZ) * .pi / 180
        )
        // Create quaternion from Euler angles (Order: Z, Y, X is standard for Unity/RealityKit usually)
        return simd_quatf(angle: angles.x, axis: [1, 0, 0]) *
               simd_quatf(angle: angles.y, axis: [0, 1, 0]) *
               simd_quatf(angle: angles.z, axis: [0, 0, 1])
    }
}
