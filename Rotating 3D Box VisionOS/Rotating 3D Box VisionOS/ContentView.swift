//
//  ContentView.swift
//  Rotating 3D Box VisionOS
//
//  Created by Steinhauer, Jan on 2/12/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
    @State private var box: ModelEntity = {
        let boxMesh = MeshResource.generateBox(size: 0.4)
        let material = SimpleMaterial(color: .green, isMetallic: false)
        let box = ModelEntity(mesh: boxMesh, materials: [material])
        
        box.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        box.generateCollisionShapes(recursive: true)
        box.components.set(GroundingShadowComponent(castsShadow: true))
        
        box.position = SIMD3<Float>(0.0, 1.5, -2.0)
        
        return box
    }()
    
    @State private var totalRotation: Double = 0
    
    var body: some View {
        RealityView { content in
            content.add(box)
        }
        .gesture(
            RotateGesture()
                .targetedToAnyEntity()
                .onChanged { gesture in
                    let combinedDegrees = totalRotation + gesture.rotation.degrees
                    let radians = Float(Angle(degrees: combinedDegrees).radians)
                    
                    box.transform.rotation = simd_quatf(angle: radians, axis: [0, 1, 0])
                }
                .onEnded { gesture in
                    totalRotation += gesture.rotation.degrees
                }
        )
    }
}

