//
//  GameScene.swift
//  Ships
//
//  Created by Joel Hollingsworth on 4/4/21.
//

import SpriteKit

class GameScene: SKScene {

    
    var ship = Ship()
    var currentTouches = Set<UITouch>()
    
    /*
     * didMove() is called when the scene is placed into
     * the view. Initialize and setup the game here.
     */
    override func didMove(to view: SKView) {
        // CHANGED - see comment in update
        // // enable the FPS label
        // view.showsFPS = true
        print("didMove called")
        
        physicsWorld.gravity = .zero
        
        ship.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(ship)
        
    }
    


    /*
     * update() is called on for each new frame before the
     * scene is drawn. Make the code as streamlined as possible
     * since it runs (hopefully) 60 times a second.
     */
    override func update(_ currentTime: TimeInterval) {

        // CHANGED
        
        // after the videos were recorded, changes in SpriteKit
        // broke the approach of setting showsFPS inside of the
        // didMove(to:) function, so that happens here instead
        handleFPSLabel()
        
        // place all additonal update code below here
        ship.update(screen: self.frame)
        
        //touch control
        for touch in currentTouches {
            if touch.location(in: self).x < frame.midX {
                ship.turnLeft()
            }
            else {
                ship.turnRight()
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            currentTouches.insert(touch)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            currentTouches.remove(touch)
        }
    }

    

    // CHANGED

    // added the function below - see comment in update
    
    func handleFPSLabel() {
        guard let view = self.view else { return }

        if !view.showsFPS {
            view.showsFPS = true
        }
    }
}
