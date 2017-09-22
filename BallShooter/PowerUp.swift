//
//  PowerUp.swift
//  BallShooter
//
//  Created by Dylan Gray on 2017-09-22.
//  Copyright © 2017 CodeGray. All rights reserved.
//

import SpriteKit

class PowerUp {
    
    var type:PowerUpType!
    var placement:Int!
    var row:Int!
    var size:CGFloat = 40.0
    var tileSize:CGFloat!
    
    var xPosition:CGFloat!
    var yPosition:CGFloat!
    
    var contactTestBitMask:UInt32!
    var categoryBitMask:UInt32!
    var powerUpNode:SKShapeNode!
    
    enum PowerUpType {
        case Ball, Star
    }
    
    init(type: PowerUpType, placement: Int, categoryBitMask: UInt32, contactTestBitMask: UInt32, tileSize:CGFloat) {
        self.xPosition = (tileSize * CGFloat(placement)) + (tileSize / 2)
        self.yPosition = GameScene.boardPosition.height + GameScene.boardPosition.origin.y - (tileSize / 2)
        self.placement = placement
        self.tileSize = tileSize
        self.contactTestBitMask = contactTestBitMask
        self.categoryBitMask = categoryBitMask
        self.type = type
        self.row = 0
    }
    
    //Function for moving down the powerup. Returns boolean for if its still on the board
    func moveDown() -> Bool {
        self.row! += 1
        self.yPosition! -= self.tileSize
        
        let action = SKAction.moveBy(x: 0, y: -(self.tileSize), duration: 0.5)
        self.powerUpNode.run(action)
        
        if row == 9 {
            removeFromScreen()
            return false
        }
        return true
    }
    
    //Removes node from screen
    func removeFromScreen() {
        self.powerUpNode.removeFromParent()
    }
}
