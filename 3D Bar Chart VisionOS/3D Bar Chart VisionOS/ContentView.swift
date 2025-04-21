//
//  ContentView.swift
//  3D Bar Chart VisionOS
//
//  Created by Steinhauer, Jan on 21.04.25.
//

import SwiftUI
import RealityKit
import RealityKitContent
import RealityFoundation

struct BarData {
    let name: String
    let value: Float
    let color: RealityFoundation.Material
}

struct ContentView: View {
    var body: some View {
        RealityView { content in
            let materials: [RealityFoundation.Material] = [
                SimpleMaterial(color: .purple, isMetallic: true),
                SimpleMaterial(color: .red, isMetallic: true),
                SimpleMaterial(color: .blue, isMetallic: true),
                SimpleMaterial(color: .green, isMetallic: true),
                SimpleMaterial(color: .orange, isMetallic: true)
            ]

            let characters = [
                BarData(name: "Serena", value: 9, color: materials[0]),
                BarData(name: "Blair", value: 11, color: materials[1]),
                BarData(name: "Chuck", value: 8, color: materials[2]),
                BarData(name: "Dan", value: 6, color: materials[3]),
                BarData(name: "Jenny", value: 5, color: materials[4])
            ]

            let chartRoot = Entity()
            chartRoot.position = [0, 1.0, 0]

            for (index, data) in characters.enumerated() {
                let barHeight = data.value * 0.1
                let barMesh = MeshResource.generateBox(size: [0.2, barHeight, 0.2])
                let barEntity = ModelEntity(mesh: barMesh, materials: [data.color])
                barEntity.position = [Float(index) * 0.3, barHeight / 2, 0]

                
                let nameLabel = createTextEntity(text: data.name)
                nameLabel.position = [barEntity.position.x - 0.08, -0.05, 0.15]
                nameLabel.scale = [0.5, 0.5, 0.5]

                let valueLabel = createTextEntity(text: "\(Int(data.value))")
                valueLabel.position = [barEntity.position.x, barHeight + 0.05, 0]
                valueLabel.scale = [0.005, 0.005, 0.005]

                chartRoot.addChild(barEntity)
                chartRoot.addChild(nameLabel)
                chartRoot.addChild(valueLabel)
            }

            content.add(chartRoot)
        }
    }
}

func createTextEntity(text: String) -> ModelEntity {
    let mesh = MeshResource.generateText(
        text,
        extrusionDepth: 0.01,
        font: .systemFont(ofSize: 0.1),
        containerFrame: .zero,
        alignment: .center,
        lineBreakMode: .byWordWrapping
    )

    let material = SimpleMaterial(color: .white, isMetallic: false)
    let entity = ModelEntity(mesh: mesh, materials: [material])
    return entity
}
