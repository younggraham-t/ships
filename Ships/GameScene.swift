//
//  GameScene.swift
//  Ships
//
//  Created by Joel Hollingsworth on 4/4/21.
//

import SpriteKit

enum NodeNames: String {
    case ship
    case ghost
    case coin
}



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let coinSize = 10.0
    let coinLabelPosition = CGPoint(x: 100, y: 150)
    let coinCreateTime = 10.0
    let ghostCreateTime = 7.0
    
    
    var isGameOver = false
    
    var ship = Ship()
    var coinCount: Int = 0
    
    var coinTime = 0.0
    var ghostTime = 0.0
    
    var shipData = [ShipPositon]()
    var ghosts = [GhostShip]()
    
    let coinSound = SKAction.playSoundFileNamed("zapThreeToneUp.mp3", waitForCompletion: false)
    
    var currentTouches = Set<UITouch>()
    
    var coinLabel = SKLabelNode(text: "Coins: 0")
    
    /*
     * didMove() is called when the scene is placed into
     * the view. Initialize and setup the game here.
     */
    override func didMove(to view: SKView) {
        // CHANGED - see comment in update
        // // enable the FPS label
        // view.showsFPS = true
        print("didMove called")
        
        coinLabel.position = coinLabelPosition
        addChild(coinLabel)
        
        //sound effects
        
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        ship.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(ship)
        makeCoin()
        
    }
    

    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == NodeNames.ship.rawValue && nodeB.name == NodeNames.coin.rawValue {
            remove(coin: nodeB)
        } else if nodeA.name == NodeNames.coin.rawValue && nodeB.name == NodeNames.ship.rawValue {
            remove(coin: nodeA)
        }
    }

    /*
     * update() is called on for each new frame before the
     * scene is drawn. Make the code as streamlined as possible
     * since it runs (hopefully) 60 times a second.
     */
    override func update(_ currentTime: TimeInterval) {
        if isGameOver {
            return
        }
        
        if coinTime == 0.0 {
            coinTime = currentTime
            ghostTime = currentTime
            
        } else if coinTime != 0.0 && coinTime + coinCreateTime < currentTime { //LITERAL FLAW FIX
            makeCoin()
            coinTime = currentTime
        }
        
        if ghostTime != 0 && ghostTime + ghostCreateTime < currentTime { //LITERAL FLAW FIX
//            print("ghost created")
            let ghostShip = GhostShip()
            ghostShip.update(shipData: shipData)
            ghosts.append(ghostShip)
            addChild(ghostShip)
        }
        
        //move the ghost ships
        for ghost in ghosts {
            ghost.update(shipData: shipData)
        }

        
        
        // CHANGED
        
        // after the videos were recorded, changes in SpriteKit
        // broke the approach of setting showsFPS inside of the
        // didMove(to:) function, so that happens here instead
        handleFPSLabel()
        
        // place all additonal update code below here
        ship.update(screen: self.frame)
        let data = ShipPositon(position: ship.position, zRotation: ship.zRotation)
        shipData.append(data)
        
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

    func makeCoin() {
        let coin = SKShapeNode(circleOfRadius: coinSize)
        coin.fillColor = .yellow
        coin.strokeColor = .white
        
        coin.position.x = CGFloat.random(in: 2*coinSize...frame.maxX - 2*coinSize) //LITERAL FLAW FIX
        coin.position.y = CGFloat.random(in: 2*coinSize...frame.maxY - 2*coinSize) //LITERAL FLAW FIX
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coinSize) //LITERAL FLAW FIX
        coin.physicsBody?.isDynamic = false
        coin.physicsBody?.collisionBitMask = 0b0000
        coin.physicsBody?.contactTestBitMask = 0b0001
        coin.name = NodeNames.coin.rawValue
        addChild(coin)
    }
    
    func remove(coin: SKNode) {
        coinCount += 1
        coinLabel.text = String("Coins: \(coinCount)")
        
        self.run(coinSound)
        
        coin.removeFromParent()
        
        if coinCount == 2 {
            isGameOver = true
            let endLabel = SKLabelNode(text: "Game Over")
            endLabel.position = CGPoint(x: frame.midX, y: frame.midY)
            addChild(endLabel)
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
