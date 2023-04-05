//
//  Ship.swift
//  Ships
//
//  Created by Graham Young on 3/30/23.
//

import SpriteKit


class Ship : SKShapeNode {
    
    
    let r = 10.0
    let shipSpeed = 125.0
    override init() {
        super.init()
        
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: r * 2.0))
        path.addLine(to: CGPoint(x: -r, y: -r * 2.0))
        path.addLine(to: CGPoint(x: r, y: -r * 2.0))
        path.addLine(to: CGPoint(x: 0.0, y: r * 2.0))
        self.path = path.cgPath
        
        self.fillColor = .green
        self.strokeColor = .white
        self.glowWidth = 1.0
        self.isAntialiased = true
        
        self.physicsBody = SKPhysicsBody(polygonFrom: path.cgPath)
        self.physicsBody?.collisionBitMask = 0b0000
        self.physicsBody?.contactTestBitMask = 0b0001
        self.name = NodeNames.ship.rawValue
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(screen: CGRect) {
        //rotate the initial rotation by pi/2 because it starts at 0 radians and the shape points at pi/2 to start
        let theta = Double(zRotation + CGFloat.pi / 2)
        let dx = CGFloat(shipSpeed * cos(theta))
        let dy = CGFloat(shipSpeed * sin(theta))
        self.physicsBody?.velocity = CGVector(dx: dx, dy: dy)
        
        // teleport if needed
        let postionOffset = CGFloat(r * 2.0)
        let moveTo = CGFloat(-r * 2.0)
        if self.position.x - postionOffset > screen.maxX {
            handleTeleport(screen: screen, direction: .posX, moveTo: moveTo)
        }
        else if self.position.x + postionOffset < screen.minX {
            handleTeleport(screen: screen, direction: .negX, moveTo: screen.maxX + moveTo)
        }
        else if self.position.y - postionOffset > screen.maxY {
            handleTeleport(screen: screen, direction: .posY, moveTo: moveTo)
        }
        else if self.position.y + postionOffset < screen.minY {
            handleTeleport(screen: screen, direction: .negY, moveTo: screen.maxY + moveTo)
        }
        
        
    }
    enum TeleportDirection {
        case posX, negX, posY, negY
    }
    
    func handleTeleport(screen:CGRect, direction: TeleportDirection, moveTo: CGFloat) {
        
        let teleportAction: SKAction
        switch direction {
        case .posX:
            teleportAction = SKAction.moveTo(x: moveTo, duration: 0.0)
        case .negX:
            teleportAction = SKAction.moveTo(x: moveTo, duration: 0.0)
        case .posY:
            teleportAction = SKAction.moveTo(y: moveTo, duration: 0.0)
        case .negY:
            teleportAction = SKAction.moveTo(y: moveTo, duration: 0.0)
        }
        self.run(teleportAction)
    
    }
    
    let turnRadius = CGFloat.pi / 80
    let turnDuration = 0.25
    
    func turnLeft() {
        let turnAction = SKAction.rotate(byAngle: CGFloat(turnRadius), duration: turnDuration) //LITERAL FLAW FIX, DESCRIPTIVE NAME CHANGE
        self.run(turnAction)
    }
 
    func turnRight() {
        let turnAction = SKAction.rotate(byAngle: -CGFloat(turnRadius), duration: turnDuration) //LITERAL FLAW FIX, DESCRIPTIVE NAME CHANGE
        self.run(turnAction)
    }
    
    func stopShip() {
        self.physicsBody?.velocity = .zero
    }
}
