//
//  BallPU.swift
//  BallShooter
//
//  Created by Dylan Gray on 2017-09-22.
//  Copyright © 2017 CodeGray. All rights reserved.
//

import SpriteKit

class BallPU: PowerUp {
    
    var grow:Bool!
    
    init(placement: Int, categoryBitMask: UInt32, tileSize:CGFloat, mode: String) {
        super.init(type: .Ball, placement: placement, categoryBitMask: categoryBitMask, tileSize: tileSize, mode: mode)
        
        size -= 5
        grow = true
        createNode()
        oscillate()
    }
    
    func createNode() {
        let tempNode = SKShapeNode(circleOfRadius: size/2)
        tempNode.fillColor = SKColor.orange
        tempNode.strokeColor = SKColor.orange
        
        tempNode.position.x = xPosition
        tempNode.position.y = yPosition
        
        tempNode.physicsBody = SKPhysicsBody(circleOfRadius: size/2)
        
        tempNode.physicsBody?.isDynamic = false
        tempNode.physicsBody?.categoryBitMask = categoryBitMask
        tempNode.physicsBody?.collisionBitMask = 0
        tempNode.position = CGPoint(x: xPosition, y: yPosition)
        
        powerUpNode = tempNode
    }
    
    //Grow and shrink powerUp
    func oscillate() {
        if grow {
            powerUpNode.run((SKAction.scale(by: 1.25, duration: 0.5)), completion: {
                self.grow = false
                self.oscillate()
            })
        } else {
            powerUpNode.run((SKAction.scale(by: (size / (powerUpNode.xScale * size)), duration: 0.5)), completion: {
                self.grow = true
                self.oscillate()
            })
        }
    }
}
