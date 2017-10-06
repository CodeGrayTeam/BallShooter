//
//  StarPU.swift
//  BallShooter
//
//  Created by Dylan Gray on 2017-10-05.
//  Copyright © 2017 CodeGray. All rights reserved.
//

import SpriteKit

class StarPU: PowerUp {
    
    init(placement: Int, categoryBitMask: UInt32, contactTestBitMask: UInt32, tileSize:CGFloat, mode: String) {
        super.init(type: .Star, placement: placement, categoryBitMask: categoryBitMask, contactTestBitMask: contactTestBitMask, tileSize: tileSize, mode: mode)
        createNode()
        rotate()
    }
    
    func createNode() {
        let tempNode = SKSpriteNode(imageNamed: "star.png")
        
        tempNode.position.x = xPosition
        tempNode.position.y = yPosition
        tempNode.zPosition = -1
        
        tempNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 40))
        
        tempNode.physicsBody?.isDynamic = true
        tempNode.physicsBody?.categoryBitMask = categoryBitMask
        tempNode.physicsBody?.contactTestBitMask = contactTestBitMask
        tempNode.physicsBody?.collisionBitMask = 0
        tempNode.position = CGPoint(x: xPosition, y: yPosition)
        
        self.powerUpNode = tempNode
    }
    
    //rotate powerUp
    func rotate() {
        self.powerUpNode.run((SKAction.rotate(byAngle: CGFloat.pi / 2, duration: 0.75)) , completion: {
            self.rotate()
        })
    }
}
