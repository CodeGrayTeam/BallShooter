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
    var mode:String!
    
    var xPosition:CGFloat!
    var yPosition:CGFloat!
    
    var contactTestBitMask:UInt32!
    var categoryBitMask:UInt32!
    var powerUpNode:SKNode!
    
    enum PowerUpType {
        case Ball, Star
    }
    
    init(type: PowerUpType, placement: Int, categoryBitMask: UInt32, tileSize:CGFloat, mode: String) {
        self.mode = mode
        xPosition = (tileSize * CGFloat(placement)) + (tileSize / 2)
        
        if mode == "reversed" {
            yPosition = GameScene.boardPosition.origin.y + (tileSize / 2)
        } else {
            yPosition = GameScene.boardPosition.height + GameScene.boardPosition.origin.y - (tileSize / 2)
        }
        
        self.placement = placement
        self.tileSize = tileSize
        self.categoryBitMask = categoryBitMask
        self.type = type
        row = 0
    }
    
    //Function for moving down the powerup. Returns boolean for if its still on the board
    func moveDown() -> Bool {
        row! += 1
        var action:SKAction!
        
        if mode == "reversed" {
            yPosition! += tileSize
            action = SKAction.moveBy(x: 0, y: tileSize, duration: 0.5)
        } else  {
            yPosition! -= tileSize
            action = SKAction.moveBy(x: 0, y: -(tileSize), duration: 0.5)
        }
        
        powerUpNode.run(action)
        
        if row == 9 {
            removeFromScreen()
            return false
        }
        return true
    }
    
    //Removes node from screen
    func removeFromScreen() {
        powerUpNode.removeFromParent()
    }
}
