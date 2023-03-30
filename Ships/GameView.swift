//
//  GameView.swift
//  Ships
//
//  Created by Joel Hollingsworth on 4/4/21.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    
    var gameScene: SKScene {
        let scene = GameScene()

        // CHANGED

        // (original)
        // this is the approach taken in the video
        // scene.size = CGSize(width: UIScreen.main.bounds.width,
        //                     height: UIScreen.main.bounds.height)
        // scene.scaleMode = .fill
        
        // (updated)
        // this approach mirrors an updated approach
        // available since the video was recorded
        scene.scaleMode = .resizeFill

        return scene
    }
    
    var body: some View {
        SpriteView(scene: gameScene)
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
