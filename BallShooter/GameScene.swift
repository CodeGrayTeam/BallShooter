//
//  GameScene.swift
//  BallShooter
//
//  Created by Dylan Gray on 2017-09-15.
//  Copyright © 2017 CodeGray. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    static var screenHeight:CGFloat!
    static var screenWidth:CGFloat!
    static var brickSize:CGFloat!
    static var boardPosition:CGRect!
    var frames:Int!
    
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    var ballShootTimer:Timer!
    var balls = [Ball]()
    var ballCount:Int!
    var maxBallCount:Int!
    
    var bricks = [Brick]()
    var bricksHit = [String]()
    
    var roof:SKShapeNode!
    var rightWall:SKShapeNode!
    var leftWall:SKShapeNode!
    var bottom:SKShapeNode!
    var launchLine = SKShapeNode()
    var launchLineX:CGFloat = 0.0
    var launchLineY:CGFloat = 0.0
    var ballRotation:CGFloat!
    
    let ballCategory:UInt32 = 0x1 << 0
    let brickCategory:UInt32 = 0x1 << 1
    let roofCategory:UInt32 = 0x1 << 2
    let rightWallCategory:UInt32 = 0x1 << 3
    let leftWallCategory:UInt32 = 0x1 << 4
    let bottomCategory:UInt32 = 0x1 << 5
    
    enum GameState {
        case startUp, readyToPlay, playing, changeLevel, checkGameOver
    }
    var gameState:GameState!
    var gameOver:Bool!
    
    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
    
        gameState = .startUp
        ballCount = 0
        maxBallCount = 1
        frames = 0
        gameOver = false
        ballRotation = 0.0
    
        initialize()
    }
    
    func initialize() {
        createBoard()
        addWalls()
        //addBall()
        addBricks()
        moveBricksDown()
    }
    
    func createBoard() {
        
        GameScene.screenHeight = self.frame.size.height
        GameScene.screenWidth = self.frame.size.width
        GameScene.brickSize = GameScene.screenWidth / 7
        
        let boardHeight = 9 * GameScene.brickSize
        
        //Remainder is broken into 3 parts, so that the bottom can be 1/3 and the top 2/3
        let remainderHeight = (GameScene.screenHeight - boardHeight) / 3
        
        GameScene.boardPosition = CGRect(x: 0, y: remainderHeight, width: GameScene.screenWidth, height: boardHeight)
        
        //Add score label
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: GameScene.screenWidth / 2, y: GameScene.screenHeight - remainderHeight - (remainderHeight / 2))
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = remainderHeight
        scoreLabel.fontColor = UIColor.white
        self.addChild(scoreLabel)
        score = 1
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState! == GameState.readyToPlay {
            let ballX = GameScene.boardPosition.width / 2
            let ballY = GameScene.boardPosition.origin.y + 15
            
            let x = launchLineX - ballX
                
            let absX = abs(x)
            let y = launchLineY - ballY
            
            if x < 0 {
                self.ballRotation = CGFloat.pi - atan(y/absX)
            } else {
                self.ballRotation = atan(y/absX)
            }
            
            print("CHANGE: \(ballRotation)")
            
            removeLaunchLine()
            self.gameState = .playing

            
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState! == GameState.readyToPlay {
            if let touch = touches.first {
                moveLine(x: touch.location(in: self.view).x * 2, y: GameScene.screenHeight - touch.location(in: self.view).y * 2)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState! == GameState.readyToPlay {
            if let touch = touches.first {
                createLaunchLine(x: touch.location(in: self.view).x * 2, y: GameScene.screenHeight - touch.location(in: self.view).y * 2)
            } else {
                print("NIL TOUCH")
            }
        }
    }
    
    func createLaunchLine(x: CGFloat, y: CGFloat) {
        if !self.children.contains(launchLine) {
            
            launchLineX = x
            launchLineY = y
            
            var newX = x
            var newY = y
            
            let ballX = GameScene.boardPosition.width / 2
            let ballY = GameScene.boardPosition.origin.y + 15
            
            let xSlope = x - ballX
            let ySlope = y - ballY
            
            
            var points = [CGPoint(x: ballX, y: ballY), CGPoint(x: x, y: y)]
            
            
            while (newX < GameScene.screenWidth && newX > 0) && (newY < GameScene.screenHeight) {
                newX += xSlope
                newY += ySlope
                points.append(CGPoint(x: newX + xSlope, y: newY + ySlope))
            }
                
                
            launchLine = SKShapeNode(points: &points, count: points.count)
            launchLine.lineWidth = 5
            launchLine.strokeColor = SKColor.white
            launchLine.fillColor = SKColor.white
            self.addChild(launchLine)
        }
    }
    
    func removeLaunchLine() {
        if self.children.contains(launchLine) {
            launchLine.removeFromParent()
        }
    }
    
    func moveLine(x: CGFloat, y: CGFloat) {
        removeLaunchLine()
        createLaunchLine(x: x, y: y)
    }
    
    func addBricks() {
        var maxNumberOfBlocks = ceil(Double(score) / 2.0 * 0.1 + 1.0)
        
        if maxNumberOfBlocks > 7 {
            maxNumberOfBlocks = 7
        }
        
        var scoreScale = Int(floor(Double(score) * 0.025))
        
        if scoreScale > 4 {
            scoreScale = 4
        }
        
        var numberOfBlocks = Int(arc4random_uniform(UInt32(maxNumberOfBlocks))) + 2 + scoreScale
        
        if numberOfBlocks > 7 {
            numberOfBlocks = 7
        }
        var placements = [Int]()
        
        for _ in 0...numberOfBlocks - 1 {
            
            var randomPlacement = Int(arc4random_uniform(7))
            while placements.contains(randomPlacement) {
                randomPlacement = Int(arc4random_uniform(7))
            }
            placements.append(randomPlacement)
            
            let brick = Brick(value: score, placement: randomPlacement, size: GameScene.brickSize, categoryBitMask: brickCategory, contactTestBitMask: ballCategory, collisionBitMask: ballCategory)
            bricks.append(brick)
            self.addChild(brick.valueLabel)
            self.addChild(brick.brickNode)
        }
    }
    
    func addBall() {
        print("BALL: \(ballRotation)")
        let radius:CGFloat = 15.0
        let ball = Ball(image: "", borderColour: .blue, fillColour: .white, radius: radius, xPosition: GameScene.screenWidth / 2, yPosition: GameScene.boardPosition.origin.y + radius + 2, speed: 20, rotation: ballRotation!, categoryBitMask: ballCategory, contactTestBitMask: brickCategory, collisionBitMask: leftWallCategory | rightWallCategory | roofCategory | bottomCategory | brickCategory, ballNum: self.ballCount)
        balls.append(ball)
        self.addChild(ball.node)
        
        self.ballCount! += 1
    }
    
    func addWalls() {
        var roofPoints = [CGPoint(x: 0, y: (GameScene.boardPosition.height + GameScene.boardPosition.origin.y)), CGPoint(x: GameScene.screenWidth, y: (GameScene.boardPosition.height + GameScene.boardPosition.origin.y))]
        var rightWallPoints = [CGPoint(x: GameScene.screenWidth + 1, y: 0), CGPoint(x: GameScene.screenWidth + 1, y: GameScene.screenHeight)]
        var leftWallPoints = [CGPoint(x: -1, y: 0), CGPoint(x: -1, y: GameScene.screenHeight)]
        var bottomPoints = [CGPoint(x: 0, y: GameScene.boardPosition.origin.y), CGPoint(x: GameScene.screenWidth, y: GameScene.boardPosition.origin.y)]

        
        self.roof = SKShapeNode(points: &roofPoints, count: roofPoints.count)
        self.roof.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: (GameScene.boardPosition.height + GameScene.boardPosition.origin.y)), to: CGPoint(x: GameScene.screenWidth, y: (GameScene.boardPosition.height + GameScene.boardPosition.origin.y)))
        self.roof.physicsBody?.isDynamic = true
        self.roof.physicsBody?.categoryBitMask = roofCategory
        self.roof.physicsBody?.contactTestBitMask = ballCategory
        self.roof.physicsBody?.collisionBitMask = ballCategory
        
        self.rightWall = SKShapeNode(points: &rightWallPoints, count: rightWallPoints.count)
        self.rightWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: GameScene.screenWidth + 1, y: 0), to: CGPoint(x: GameScene.screenWidth + 1, y: GameScene.screenHeight))
        self.rightWall.physicsBody?.isDynamic = true
        self.rightWall.physicsBody?.categoryBitMask = rightWallCategory
        self.rightWall.physicsBody?.contactTestBitMask = ballCategory
        self.rightWall.physicsBody?.collisionBitMask = ballCategory
        
        self.leftWall = SKShapeNode(points: &leftWallPoints, count: leftWallPoints.count)
        self.leftWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -1, y: 0), to: CGPoint(x: -1, y: GameScene.screenHeight))
        self.leftWall.physicsBody?.isDynamic = true
        self.leftWall.physicsBody?.categoryBitMask = leftWallCategory
        self.leftWall.physicsBody?.contactTestBitMask = ballCategory
        self.leftWall.physicsBody?.collisionBitMask = ballCategory
        
        self.bottom = SKShapeNode(points: &bottomPoints, count: bottomPoints.count)
        self.bottom.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: GameScene.boardPosition.origin.y), to: CGPoint(x: GameScene.screenWidth, y: GameScene.boardPosition.origin.y))
        self.bottom.physicsBody?.isDynamic = true
        self.bottom.physicsBody?.categoryBitMask = bottomCategory
        self.bottom.physicsBody?.contactTestBitMask = ballCategory
        self.bottom.physicsBody?.collisionBitMask = ballCategory
        
        self.addChild(self.roof)
        self.addChild(self.rightWall)
        self.addChild(self.leftWall)
        self.addChild(self.bottom)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        let countPoint = true
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & ballCategory) != 0 {
            if (firstBody.node != nil && secondBody.node != nil){
                if (secondBody.categoryBitMask & brickCategory) != 0  {
                    if !bricksHit.contains("\(secondBody.node?.name ?? ""), \(firstBody.node?.name ?? "")") {
                        //If ball hasnt hit the object more than once
                        bricksHit.append("\(secondBody.node?.name ?? ""), \(firstBody.node?.name ?? "")")
                        
                        ballDidHitBrick(ballNode: firstBody.node as! SKShapeNode, brickNode: secondBody.node as! SKShapeNode, decreasePoint: countPoint, contact: contact)
                    }
                } else if (secondBody.categoryBitMask & roofCategory) != 0 || (secondBody.categoryBitMask & rightWallCategory) != 0 || (secondBody.categoryBitMask & leftWallCategory) != 0 || (secondBody.categoryBitMask & bottomCategory) != 0 {
                    ballDidHitWall(ballNode: firstBody.node as! SKShapeNode, wallNode: secondBody.node as! SKShapeNode)
                } else {
                    //Nothing as of yet
                }
            }
        }
    }
    
    func retreiveBricksWithMultipleContatcs(ballPhysicsBody:SKPhysicsBody, brickPhysicsBody:SKPhysicsBody) -> [String] {
        var brickNames = [String]()
        var dupBrickNames = [String]()
        
        for body in ballPhysicsBody.allContactedBodies() {
            if !brickNames.contains((body.node?.name)!) {
                brickNames.append((body.node?.name)!)
            } else {
                dupBrickNames.append((body.node?.name)!)
            }
        }
        
        return dupBrickNames
    }
    
    func ballDidHitBrick(ballNode:SKShapeNode, brickNode:SKShapeNode, decreasePoint: Bool, contact: SKPhysicsContact) {
        var ball:Ball!
        var brick:Brick!
        
        for i in (0...balls.count - 1).reversed() {
            if balls[i].node == ballNode {
                ball = balls[i]
                break
            }
        }
        
        var index = 0
        for j in (0...bricks.count - 1).reversed() {
            if bricks[j].brickNode == brickNode {
                brick = bricks[j]
                index = j
                ball.changeDirection(brick: brick, contact: contact)
                brick.decreaseValue()
                break
            }
        }
        
        if brick.value == 0 {
            bricks.remove(at: index)
        }
    }
    
    func ballDidHitWall(ballNode:SKShapeNode, wallNode:SKShapeNode) {
        
        for i in (0...balls.count - 1).reversed() {
            if balls[i].node == ballNode {
                if wallNode.physicsBody?.categoryBitMask == roofCategory {
                    //The roof is technically like hitting the bottom of a brick
                    balls[i].changeYDirection(isTop: false)
                } else if wallNode.physicsBody?.categoryBitMask == bottomCategory {
                    //Remove ball if it hits the bottom
                    self.balls[i].node.removeFromParent()
                    self.balls.remove(at: i)

                    if balls.count == 0 {
                        changeLevel()
                    }
                    
                } else if wallNode.physicsBody?.categoryBitMask == rightWallCategory {
                    //The right wall is technically like hitting the left side of a brick
                    balls[i].changeXDirection(isRight: false)
                } else {
                    //The left wall is technically like hitting the right side of a brick
                    balls[i].changeXDirection(isRight: true)
                }
            }
        }
    }
    
    func changeLevel() {
        gameState = .changeLevel
        ballCount = 0
        maxBallCount! += 1
        score += 1
        addBricks()
        moveBricksDown()
    }
    
    func moveBricksDown() {
        if bricks.count > 0 {
            for i in 0...bricks.count - 1 {
                bricks[i].moveDown()
                if bricks[i].row == 8 {
                    gameOver = true
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
            self.gameState = .checkGameOver
        })
    }
    
    func endGame() {
        bricks.forEach({ brick1 in
            brick1.valueLabel.removeFromParent()
            brick1.brickNode.removeFromParent()
        })
        bricks.removeAll()
        gameOver = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        switch gameState! {
        case .startUp:
            //Nothing as of yet
            break
        case .readyToPlay:
            //Nothing as of yet
            break
        case .playing:
            if balls.count > 0 {
                for i in 0...balls.count - 1 {
                    balls[i].moveBall()
                }
            }
            
            // Called before each frame is rendered
            if frames % 5 == 0 && ballCount < maxBallCount && ballRotation! != 0.0 {
                addBall()
                frames = 0
            }
            
            frames! += 1

            break
        case .changeLevel:
            //Nothing as of yet
            break
        case .checkGameOver:
            
            if gameOver {
                gameState = .startUp
                endGame()
            } else {
                gameState = .readyToPlay
            }
            
            break
        }
    }
    
    override func didFinishUpdate() {
        bricksHit.removeAll()
    }
}
