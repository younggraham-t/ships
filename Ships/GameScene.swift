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

struct GameSceneConstants {
    static let restartCountdownDefaultValue = 300
    static let coinSize = 10.0
    static let coinLabelPosition = CGPoint(x: 100, y: 150)
    static let coinCreateTime = 10.0
    static let ghostCreateTime = 7.0
    static let endGameCoinCount = 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    

    
    
    var isGameOver = false
    
    var ship = Ship()
    var coinCount: Int = 0
    
    var coinTime = 0.0
    var ghostTime = 0.0
    var restartCounter = GameSceneConstants.restartCountdownDefaultValue // 600/60 = 10 (10 second countdown)
    
    var shipData = [ShipPositon]()
    var ghosts = [GhostShip]()
    
    
    //sound effects
    let coinSound = SKAction.playSoundFileNamed("zapThreeToneUp.mp3", waitForCompletion: false)
    let lossSound = SKAction.playSoundFileNamed("zapThreeToneDown.mp3", waitForCompletion: false)
    
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
        
        setupGame()
        
    }
    
    func resetAllVariables() {
        self.removeAllChildren()
        isGameOver = false
        ship = Ship()
        coinCount = 0
        coinTime = 0.0
        ghostTime = 0.0
        restartCounter = GameSceneConstants.restartCountdownDefaultValue // 600/60 = 10 (10 second countdown)
        shipData = [ShipPositon]()
        ghosts = [GhostShip]()
        currentTouches = Set<UITouch>()
        coinLabel = SKLabelNode(text: "Coins: 0")
    }
    
    
    func setupGame() {
        //reset the game for later calls of setupGame
        self.resetAllVariables() //does nothing on initial call
        
        coinLabel.position = GameSceneConstants.coinLabelPosition
        addChild(coinLabel)
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        ship.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(ship)
        makeCoin()

        
    }
    

    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        switch nodeA.name {
            
        case NodeNames.ship.rawValue: //nodeA is a ship
            handleShipCase(shipNode: nodeA, nonShipNode: nodeB)
            return
            
        case NodeNames.coin.rawValue, NodeNames.ghost.rawValue: //nodeA isn't a ship
            break
            
        case _: // should never happen as long as the names are correct
            //probably should throw an error but it shouldn't be a problem and i dont want to deal with that right now
            print("invalid name for nodeA")
            
        }
        
        switch nodeB.name {
            
        case NodeNames.ship.rawValue: //nodeB is a ship
            handleShipCase(shipNode: nodeB, nonShipNode: nodeA)
            return
            
        case NodeNames.coin.rawValue, NodeNames.ghost.rawValue: //nodeB isn't a ship
            break
            
        case _: // should never happen as long as the names are correct
            //probably should throw an error but it shouldn't be a problem and i dont want to deal with that right now
            print("invalid name for nodeB")
        }
        
    }
    
    func handleShipCase(shipNode: SKNode, nonShipNode: SKNode) {
        switch nonShipNode.name {
            
        case NodeNames.coin.rawValue: // if nonShipNode is a coin remove the coin and continue
            remove(node: nonShipNode) //remove(node:) calls remove(coin:) if it's a coin
            return
            
        case NodeNames.ghost.rawValue: // if nonShipNode is a ghost remove the ship and end the game
            remove(node: shipNode)
            run(lossSound)
            endGame(isWin: false)
            return
            
        case _: // should never happen as long as the names are correct
            //probably should throw an error but it shouldn't be a problem and i dont want to deal with that right now
            print("invalid name for nonShipNode")
            return
        }
    }

    var playAgainLabel = SKLabelNode()
    /*
     * update() is called on for each new frame before the
     * scene is drawn. Make the code as streamlined as possible
     * since it runs (hopefully) 60 times a second.
     */
    override func update(_ currentTime: TimeInterval) {
        if isGameOver {
            handleRestartTimer()
            return
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
        
        handleCoinCreation(currentTime)
        
        handleGhostCreation(currentTime)
        
        handleGhostMovement()

        handleTouchControl()
        
        
    }
    
    func handleRestartTimer() {
        if  restartCounter % 60 == 0 {
            
            playAgainLabel.removeFromParent()
            playAgainLabel = SKLabelNode(text: "Play Again? \(restartCounter / 60)")
            playAgainLabel.position = CGPoint(x: frame.midX, y: frame.maxY - playAgainLabel.frame.height)
            addChild(playAgainLabel)
        }
        restartCounter -= 1
        if restartCounter <= 0 {
            setupGame()
        }
        
    }
    
    func handleCoinCreation(_ currentTime: TimeInterval) {
        if coinTime == 0.0 {
            coinTime = currentTime
            ghostTime = currentTime
            
        } else if coinTime != 0.0 && coinTime + GameSceneConstants.coinCreateTime < currentTime { //LITERAL FLAW FIX
            makeCoin()
            coinTime = currentTime
        }
    }
    
    func handleGhostCreation(_ currentTime: TimeInterval) {
        if ghostTime != 0 && ghostTime + GameSceneConstants.ghostCreateTime < currentTime { //LITERAL FLAW FIX
//            print("ghost created")
            let ghostShip = GhostShip()
            let _ = ghostShip.update(shipData: shipData)
            ghosts.append(ghostShip)
            addChild(ghostShip)
            ghostTime = currentTime
        }
    }
    
    func handleGhostMovement() {
        //move the ghost ships
        for ghost in ghosts {
            let shouldRemove = ghost.update(shipData: shipData)
            if shouldRemove {
                remove(node: ghost)
            }
        }
    }
    
    func handleTouchControl() {
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
        let coin = SKShapeNode(circleOfRadius: GameSceneConstants.coinSize)
        coin.fillColor = .yellow
        coin.strokeColor = .white
        
        coin.position.x = CGFloat.random(in: 2*GameSceneConstants.coinSize...frame.maxX - 2*GameSceneConstants.coinSize) //LITERAL FLAW FIX
        coin.position.y = CGFloat.random(in: 2*GameSceneConstants.coinSize...frame.maxY - 2*GameSceneConstants.coinSize) //LITERAL FLAW FIX
        coin.physicsBody = SKPhysicsBody(circleOfRadius: GameSceneConstants.coinSize) //LITERAL FLAW FIX
        coin.physicsBody?.isDynamic = false
        coin.physicsBody?.collisionBitMask = 0b0000
        coin.physicsBody?.contactTestBitMask = 0b0001
        coin.name = NodeNames.coin.rawValue
        addChild(coin)
    }
    
    func remove(node: SKNode) {
        switch node.name {
        case NodeNames.coin.rawValue:
            remove(coin: node)
            return
        case NodeNames.ship.rawValue, NodeNames.ghost.rawValue:
            node.removeFromParent()
            return
        case _:
            print("Invalid name")
            return
        }
    }
    
    func remove(coin: SKNode) {
        coinCount += 1
        coinLabel.text = String("Coins: \(coinCount)")
        
        self.run(coinSound)
        
        coin.removeFromParent()
        
        if coinCount == GameSceneConstants.endGameCoinCount {
            endGame(isWin: true)

        }
    }
    
    func endGame(isWin: Bool) {
        isGameOver = true
        let labelText = isWin ? "You Win!" : "Game Over"
        let endLabel = SKLabelNode(text: labelText)
        endLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(endLabel)
        ship.stopShip()
        
        
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
