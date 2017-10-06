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
    
    init(placement: Int, categoryBitMask: UInt32, contactTestBitMask: UInt32, tileSize:CGFloat, mode: String) {
        super.init(type: .Ball, placement: placement, categoryBitMask: categoryBitMask, contactTestBitMask: contactTestBitMask, tileSize: tileSize, mode: mode)
        
        self.size -= 5
        self.grow = true
        createNode()
        oscillate()
    }
    
    func createNode() {
        let tempNode = SKShapeNode(circleOfRadius: self.size/2)
        tempNode.fillColor = SKColor.orange
        tempNode.strokeColor = SKColor.orange
        
        tempNode.position.x = xPosition
        tempNode.position.y = yPosition
        
        tempNode.physicsBody = SKPhysicsBody(circleOfRadius: self.size/2)
        
        tempNode.physicsBody?.isDynamic = true
        tempNode.physicsBody?.categoryBitMask = categoryBitMask
        tempNode.physicsBody?.contactTestBitMask = contactTestBitMask
        tempNode.physicsBody?.collisionBitMask = 0
        tempNode.position = CGPoint(x: xPosition, y: yPosition)
        
        self.powerUpNode = tempNode
    }
    
    //Grow and shrink powerUp
    func oscillate() {
        if self.grow {
            self.powerUpNode.run((SKAction.scale(by: 1.25, duration: 0.5)), completion: { 
                self.grow = false
                self.oscillate()
            })
        } else {
            self.powerUpNode.run((SKAction.scale(by: (self.size / (self.powerUpNode.xScale * self.size)), duration: 0.5)), completion: { 
                self.grow = true
                self.oscillate()
            })
        }
    }
}
