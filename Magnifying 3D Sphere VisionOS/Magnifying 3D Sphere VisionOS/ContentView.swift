//
//  ContentView.swift
//  Magnifying 3D Sphere VisionOS
//
//  Created by Steinhauer, Jan on 2/12/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
    @State private var sphere: ModelEntity = {
        let sphereMesh = MeshResource.generateSphere(radius: 0.4)
        let material = SimpleMaterial(color: .green, isMetallic: false)
        let sphere = ModelEntity(mesh: sphereMesh, materials: [material])
        
        sphere.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        sphere.generateCollisionShapes(recursive: true)
        sphere.components.set(GroundingShadowComponent(castsShadow: true))
        
        sphere.position = SIMD3<Float>(0.0, 1.5, -2.0)
        
        return sphere
    }()
    
    @State private var itemScale: Float = 1.0
    
    @State private var gestureScale: Float = 1.0
    
    var body: some View {
        RealityView { content in
            content.add(sphere)
        }
        .gesture(
            MagnifyGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    gestureScale = Float(value.magnification)
                    
                    sphere.scale = SIMD3<Float>(repeating: itemScale * gestureScale)
                }
                .onEnded { value in
                    itemScale *= Float(value.magnification)
                    
                    gestureScale = 1.0
                }
        )
    }
}
