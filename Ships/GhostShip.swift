//
//  GhostShip.swift
//  Ships
//
//  Created by Graham Young on 4/5/23.
//

import SpriteKit

class GhostShip: Ship {
    
    private var currentMove = 0
    
    override init() {
        super.init()
        self.fillColor = .gray
        self.name = NodeNames.ghost.rawValue
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(shipData: [ShipPositon]) {
//        print("ghost updates")
        self.position.x = shipData[currentMove].position.x
        self.position.y = shipData[currentMove].position.y
        self.zRotation = shipData[currentMove].zRotation
        currentMove += 1
    }
}
