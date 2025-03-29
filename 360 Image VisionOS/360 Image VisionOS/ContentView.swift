//
//  ContentView.swift
//  360 Image VisionOS
//
//  Created by Steinhauer, Jan on 29.03.25.
//

import SwiftUI
import AVFoundation
import RealityKit

class VideoViewModel: ObservableObject {
    @Published var avPlayer = AVPlayer()
    @Published var playerItem: AVPlayerItem?
    
    func setupPlayerItem(from urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        avPlayer.replaceCurrentItem(with: item)
        playerItem = item
    }
}

struct ContentView: View {
    @StateObject private var viewModel = VideoViewModel()

    var body: some View {
        RealityView { content in
            let entity = setupContentEntity()
            content.add(entity)
        }
        .onAppear {
            viewModel.setupPlayerItem(from: "https://firebasestorage.googleapis.com/v0/b/vivamonarch-b34f3.appspot.com/o/Monarch6.mp4?alt=media&token=b8b6bb34-ce96-426e-9c03-ee2947883e94")
        }
    }
    
    private func setupContentEntity() -> Entity {
        let contentEntity = Entity()
        
        do {
            let sphere = try Entity.load(named: "Sphere")
            sphere.scale = .init(x: 1E3, y: 1E3, z: 1E3)
            
            if let modelEntity = sphere.findEntity(named: "Sphere") as? ModelEntity {
                let avPlayerMaterial = VideoMaterial(avPlayer: viewModel.avPlayer)
                modelEntity.model?.materials = [avPlayerMaterial]
            } else {
                print("[ContentView] Failed to find model entity in sphere")
            }
            
            contentEntity.addChild(sphere)
            contentEntity.scale = .one
            contentEntity.scale *= .init(x: -1, y: 1, z: 1)
        } catch {
            print("[ContentView] Failed to load sphere entity: \(error.localizedDescription)")
        }
        
        return contentEntity
    }
}
