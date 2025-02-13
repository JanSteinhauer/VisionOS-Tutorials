//
//  ContentView.swift
//  Pie Chart VisionOS
//
//  Created by Steinhauer, Jan on 2/13/25.
//

import SwiftUI
import RealityKit
import RealityKitContent
import UIKit

struct GossipGirl: Identifiable {
    let id = UUID()
    let character: String
    let screentime: Double
}

struct ContentView: View {
    @State private var gossipGirl: [GossipGirl] = [
        .init(character: "Dan", screentime: 0.6),
        .init(character: "Serena", screentime: 0.2),
        .init(character: "Blair", screentime: 0.1),
        .init(character: "Chuck", screentime: 0.1),
    ]
    
    var body: some View {
        RealityView { content in
            let pieChartEntity = make3DPieChart(from: gossipGirl)
            
            pieChartEntity.transform.translation = SIMD3<Float>(0, 1.5, -1)
            pieChartEntity.transform.rotation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
            
            content.add(pieChartEntity)
        }
    }
    
    // MARK: - Create the full 3D pie chart
    private func make3DPieChart(from slices: [GossipGirl]) -> Entity {
        let pieChartParent = Entity()
        
        var startAngle: Float = 0
        for slice in slices {
            // Calculate angle in radians for this slice
            let totalAngle = 2 * Float.pi * Float(slice.screentime)
            let endAngle   = startAngle + totalAngle
            
            // Create the wedge model for this slice
            let sliceEntity = createSliceEntity(
                slice: slice,
                startAngle: startAngle,
                endAngle: endAngle,
                radius: 0.5,
                height: 0.1,
                color: randomColor()
            )
            
            pieChartParent.addChild(sliceEntity)
            startAngle += totalAngle
        }
        return pieChartParent
    }
    
    // MARK: - Create a single wedge (pie slice) + label text
    private func createSliceEntity(
        slice: GossipGirl,
        startAngle: Float,
        endAngle: Float,
        radius: Float,
        height: Float,
        color: UIColor
    ) -> ModelEntity {
        
        // Generate the mesh for a slice from startAngle to endAngle
        let sliceMesh = generatePieSliceMesh(
            startAngle: startAngle,
            endAngle: endAngle,
            radius: radius,
            height: height
        )
        
        let material = SimpleMaterial(color: color, roughness: 0.3, isMetallic: false)
        let modelEntity = ModelEntity(mesh: sliceMesh, materials: [material])
        
        
        print("startAngle \(startAngle)")
        print("endAngle \(endAngle)")
        print("radius \(radius)")

        // Create a 3D text entity with the character name
        let textEntity = createTextEntity(
            slice.character,
            startAngle: startAngle,
            endAngle: endAngle,
            radius: radius,
            height: 0.0001
        )
        
        textEntity.transform.scale = [1, 1, 0.01]
        modelEntity.addChild(textEntity)
        
        return modelEntity
    }
    
    // MARK: - Create the 3D Text Label
    private func createTextEntity(
        _ text: String,
        startAngle: Float,
        endAngle: Float,
        radius: Float,
        height: Float
    ) -> ModelEntity {
        
        // We'll find the midpoint angle so we can place the text above
        // the middle of this wedge.
        let midAngle = (startAngle + endAngle) / 2
        // Place the text about halfway to the outer edge
        let midRadius = radius * 0.5
        
        // Generate a 3D text mesh. Adjust `extrusion` or font size as needed.
        let textMesh = MeshResource.generateText(
            text,
            font: .systemFont(ofSize: 0.035),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        
        // Create a RealityKit ModelEntity for the text
        let textMaterial = SimpleMaterial(color: .white, roughness: 0.5, isMetallic: false)
        let textEntity   = ModelEntity(mesh: textMesh, materials: [textMaterial])
        
        // Position the text slightly above the top face of the wedge
        // so it doesn’t clip into the wedge geometry.
        let xPos = midRadius * cos(midAngle)
        let zPos = midRadius * sin(midAngle)
        textEntity.transform.translation = [xPos, height / 2 + 0.02, zPos]
        
        // Optionally rotate the text so it faces outward
        // (the +.pi/2 helps ensure the text isn't sideways)
        textEntity.transform.rotation = simd_quatf(angle: -(180) + .pi/2, axis: [1,0,0])
        
        return textEntity
    }
    
    // MARK: - Build wedge mesh
    private func generatePieSliceMesh(
        startAngle: Float,
        endAngle: Float,
        radius: Float,
        height: Float
    ) -> MeshResource {
        
        let angleDelta = endAngle - startAngle
        
        // Number of segments used to approximate the arc
        let segments = 20
        let angleStep = angleDelta / Float(segments)
        
        var positions: [SIMD3<Float>] = []
        var normals: [SIMD3<Float>] = []
        var texCoords: [SIMD2<Float>] = []
        var indices: [UInt32] = []
        
        // --- Top Face (triangle fan) ---
        let topCenterIndex = UInt32(positions.count)
        positions.append(SIMD3<Float>(0, height / 2, 0))
        normals.append(SIMD3<Float>(0, 1, 0))
        texCoords.append(SIMD2<Float>(0.5, 0.5))
        
        // Outer points (top face ring)
        for i in 0...segments {
            let theta = startAngle + Float(i) * angleStep
            let x = radius * cos(theta)
            let z = radius * sin(theta)
            
            positions.append(SIMD3<Float>(x, height / 2, z))
            normals.append(SIMD3<Float>(0, 1, 0))
            texCoords.append(SIMD2<Float>((cos(theta) + 1) / 2,
                                          (sin(theta) + 1) / 2))
        }
        
        // Indices for top face (triangle fan)
        for i in 0..<segments {
            indices.append(topCenterIndex)
            indices.append(topCenterIndex + 1 + UInt32(i))
            indices.append(topCenterIndex + 2 + UInt32(i))
        }
        
        // --- Bottom Face (triangle fan) ---
        let bottomCenterIndex = UInt32(positions.count)
        positions.append(SIMD3<Float>(0, -height / 2, 0))
        normals.append(SIMD3<Float>(0, -1, 0))
        texCoords.append(SIMD2<Float>(0.5, 0.5))
        
        let bottomStartIndex = UInt32(positions.count)
        for i in 0...segments {
            let theta = startAngle + Float(i) * angleStep
            let x = radius * cos(theta)
            let z = radius * sin(theta)
            
            positions.append(SIMD3<Float>(x, -height / 2, z))
            normals.append(SIMD3<Float>(0, -1, 0))
            texCoords.append(SIMD2<Float>((cos(theta) + 1) / 2,
                                          (sin(theta) + 1) / 2))
        }
        
        // Indices for bottom face (triangle fan; reversed to keep normals outward)
        for i in 0..<segments {
            indices.append(bottomCenterIndex)
            indices.append(bottomStartIndex + UInt32(i + 1))
            indices.append(bottomStartIndex + UInt32(i))
        }
        
        // --- Side Faces ---
        // Connect top ring and bottom ring with quads (two triangles per quad)
        let topStartIndex = topCenterIndex + 1
        let bottomStartIdx = bottomCenterIndex + 1
        
        for i in 0..<segments {
            let topA = topStartIndex + UInt32(i)
            let topB = topStartIndex + UInt32(i + 1)
            let botA = bottomStartIdx + UInt32(i)
            let botB = bottomStartIdx + UInt32(i + 1)
            
            // Quad -> two triangles
            // Triangle 1
            indices.append(topA)
            indices.append(botA)
            indices.append(botB)
            
            // Triangle 2
            indices.append(topA)
            indices.append(botB)
            indices.append(topB)
        }
        
        // Build MeshDescriptor
        var descriptor = MeshDescriptor()
        descriptor.positions = MeshBuffers.Positions(positions)
        descriptor.normals = MeshBuffers.Normals(normals)
        descriptor.textureCoordinates = MeshBuffers.TextureCoordinates(texCoords)
        descriptor.primitives = .triangles(indices)
        
        // Create the actual RealityKit mesh
        return try! MeshResource.generate(from: [descriptor])
    }
    
    // MARK: - Helper for wedge colors
    private func randomColor() -> UIColor {
        UIColor(
            red:   .random(in: 0.2...0.8),
            green: .random(in: 0.2...0.8),
            blue:  .random(in: 0.2...0.8),
            alpha: 1.0
        )
    }
}
