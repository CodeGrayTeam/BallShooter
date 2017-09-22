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
    
    init(placement: Int, categoryBitMask: UInt32, contactTestBitMask: UInt32, tileSize:CGFloat) {
        super.init(type: .Ball, placement: placement, categoryBitMask: categoryBitMask, contactTestBitMask: contactTestBitMask, tileSize: tileSize)
        
        self.size -= 5
        self.grow = true
        createNode()
        oscillate()
    }
    
    func createNode() {
        self.powerUpNode = SKShapeNode(circleOfRadius: self.size/2)
        self.powerUpNode.fillColor = SKColor.orange
        self.powerUpNode.strokeColor = SKColor.orange
        
        self.powerUpNode.position.x = xPosition
        self.powerUpNode.position.y = yPosition
        
        self.powerUpNode.physicsBody = SKPhysicsBody(circleOfRadius: self.size/2)
        
        self.powerUpNode.physicsBody?.isDynamic = true
        self.powerUpNode.physicsBody?.categoryBitMask = categoryBitMask
        self.powerUpNode.physicsBody?.contactTestBitMask = contactTestBitMask
        self.powerUpNode.physicsBody?.collisionBitMask = 0
        self.powerUpNode.position = CGPoint(x: xPosition, y: yPosition)
    }
    
    //Grow and shrink powerUp
    func oscillate() {
        if self.grow {
            self.powerUpNode.run((SKAction.scale(by: 1.25, duration: 0.5)), completion: { _ in
                self.grow = false
                self.oscillate()
            })
        } else {
            self.powerUpNode.run((SKAction.scale(by: (self.size / (self.powerUpNode.xScale * self.size)), duration: 0.5)), completion: { _ in
                self.grow = true
                self.oscillate()
            })
        }
    }
}
