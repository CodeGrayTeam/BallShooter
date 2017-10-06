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
    
    var viewController: GameViewController!
    var mode:String!
    
    static var screenHeight:CGFloat!
    static var screenWidth:CGFloat!
    static var brickSize:CGFloat!
    static var boardPosition:CGRect!
    var frames:Int!
    
    var starCountLabel:SKLabelNode!
    var starLabel:SKSpriteNode!
    var highscoreLabel:SKLabelNode!
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    var newPositionMarker:SKLabelNode!
    var numBallsLabel:SKLabelNode!
    var numBalls:Int = 1 {
        didSet {
            numBallsLabel.text = "x\(numBalls)"
        }
    }
    
    var ballShootTimer:Timer!
    var balls = [Ball]()
    var ballCount:Int!
    var maxBallCount:Int!
    
    var bricks = [Brick]()
    var bricksHit = [String]()
    
    var powerUps = [PowerUp]()
    var additionalBalls = 0
    
    var roof:SKShapeNode!
    var rightWall:SKShapeNode!
    var leftWall:SKShapeNode!
    var bottom:SKShapeNode!
    
    var launchLine = SKShapeNode()
    var launchLineX:CGFloat = 0.0
    var launchLineY:CGFloat = 0.0
    var ballX:CGFloat!
    var newBallX:CGFloat!
    var ballY:CGFloat!
    var ballRadius:CGFloat = 15.0
    
    var ballRotation:CGFloat!
    var firstBallEnded:Bool!
    
    let ballCategory:UInt32 = 0x1 << 0
    let brickCategory:UInt32 = 0x1 << 1
    let roofCategory:UInt32 = 0x1 << 2
    let rightWallCategory:UInt32 = 0x1 << 3
    let leftWallCategory:UInt32 = 0x1 << 4
    let bottomCategory:UInt32 = 0x1 << 5
    let powerUpCategory:UInt32 = 0x1 << 6
    
    enum GameState {
        case startUp, readyToPlay, playing, changeLevel, checkGameOver, endGame
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
        firstBallEnded = false
        ballRotation = 0.0
    
        initialize()
    }
    
    func initialize() {
        createBoard()
        ballX = GameScene.boardPosition.width / 2
        ballY = GameScene.boardPosition.origin.y + 2
        addWalls()
        addPowerUp()
        addBricks()
        moveObjectsDown()
    }
    
    func createBoard() {
        
        GameScene.screenHeight = self.frame.size.height
        GameScene.screenWidth = self.frame.size.width
        GameScene.brickSize = GameScene.screenWidth / 7
        
        let boardHeight = 9 * GameScene.brickSize
        
        //Remainder is broken into 3 parts, so that the bottom can be 1/3 and the top 2/3
        let remainderHeight = (GameScene.screenHeight - boardHeight) / 3
        
        GameScene.boardPosition = CGRect(x: 0, y: remainderHeight, width: GameScene.screenWidth, height: boardHeight)
        
        //Add highscore label
        let defaults = UserDefaults.standard
        highscoreLabel = SKLabelNode(text: "Best: \(defaults.object(forKey: "\(mode!)HighScore") as? Int ?? 1)")
        highscoreLabel.position = CGPoint(x: 100, y: GameScene.screenHeight - remainderHeight - 15)
        highscoreLabel.fontName = "AmericanTypewriter-Bold"
        highscoreLabel.fontSize = 30
        highscoreLabel.fontColor = UIColor.white
        self.addChild(highscoreLabel)
        
        //Add stars label
        starCountLabel = SKLabelNode(text: "\(defaults.object(forKey: "stars") as? Int ?? 0)")
        starCountLabel.position = CGPoint(x: GameScene.screenWidth - 80, y: GameScene.screenHeight - remainderHeight - 15)
        starCountLabel.fontName = "AmericanTypewriter-Bold"
        starCountLabel.fontSize = 30
        starCountLabel.fontColor = UIColor.white
        self.addChild(starCountLabel)
        
        starLabel = SKSpriteNode(imageNamed: "star.png")
        starLabel.position = CGPoint(x: GameScene.screenWidth - 130, y: GameScene.screenHeight - remainderHeight)
        self.addChild(starLabel)
        
        //Add score label
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: GameScene.screenWidth / 2, y: GameScene.screenHeight - remainderHeight - (remainderHeight / 3))
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = remainderHeight
        scoreLabel.fontColor = UIColor.white
        self.addChild(scoreLabel)
        score = 1
        
        //Add ball amount label
        numBallsLabel = SKLabelNode(text: "x1")
        numBallsLabel.position = CGPoint(x: GameScene.screenWidth / 2, y: remainderHeight - 20)
        numBallsLabel.fontName = "AmericanTypewriter-Bold"
        numBallsLabel.fontSize = 20
        numBallsLabel.fontColor = UIColor.white
        self.addChild(numBallsLabel)
        
        //Add new ball position label
        newPositionMarker = SKLabelNode(text: "x")
        newPositionMarker.position = CGPoint(x: GameScene.screenWidth / 2, y: remainderHeight + 5)
        newPositionMarker.fontName = "AmericanTypewriter-Bold"
        newPositionMarker.fontSize = 20
        newPositionMarker.fontColor = UIColor.white
        newPositionMarker.isHidden = true
        self.addChild(newPositionMarker)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState! == GameState.readyToPlay && self.children.contains(launchLine) {
            let x = launchLineX - ballX
            
            let ballLaunchY = ballY + ballRadius
            let absX = abs(x)
            
            let y = launchLineY - ballLaunchY
            
            if x < 0 {
                self.ballRotation = CGFloat.pi - atan(y/absX)
            } else {
                self.ballRotation = atan(y/absX)
            }
            
            //Only accept degrees from 5 - 175
            if self.ballRotation > CGFloat.pi / 36 && self.ballRotation < CGFloat.pi - (CGFloat.pi / 36) {
                removeBall(index: 0)
                ballCount = 0
                self.gameState = .playing
            }
            
            removeLaunchLine()
            
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
            
            let ballLaunchY = ballY + ballRadius
            
            let xSlope = x - ballX
            let ySlope = y - ballLaunchY
            let slope = ySlope / xSlope
            let b = ballLaunchY - slope * ballX
            
            
            var points = [CGPoint(x: ballX, y: ballLaunchY), CGPoint(x: x, y: y)]
            
            
            while (newX < GameScene.screenWidth && newX > 0) && (newY < GameScene.boardPosition.origin.y + GameScene.boardPosition.height && newY > GameScene.boardPosition.origin.y) {
                newX += xSlope
                newY += ySlope
                
                if newY > GameScene.boardPosition.origin.y + GameScene.boardPosition.height {
                    newY = GameScene.boardPosition.origin.y + GameScene.boardPosition.height
                    newX = (newY - b) / slope
                }
                
                points.append(CGPoint(x: newX, y: newY))
            }
                
            launchLine = SKShapeNode(points: &points, count: points.count)
            launchLine.lineWidth = 2
            launchLine.strokeColor = SKColor.white
            launchLine.fillColor = SKColor.white
            self.addChild(launchLine)
            
            let diffX = launchLineX - ballX
            let absX = abs(diffX)
            let diffY = launchLineY - ballLaunchY
            
            if diffX < 0 {
                self.ballRotation = CGFloat.pi - atan(diffY/absX)
            } else {
                self.ballRotation = atan(diffY/absX)
            }
            
            //Only accept degrees from 5 - 175
            if self.ballRotation > CGFloat.pi / 36 && self.ballRotation < CGFloat.pi - (CGFloat.pi / 36) {
                self.launchLine.isHidden = false
            } else {
                self.launchLine.isHidden = true
            }
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
    
    func updateRotation() {
        balls[0].rotation = ballRotation
        balls[0].calculateSpeeds()
    }
    
    func addBricks() {
        
        if mode == "bombDrop" && score % 2 != 0 {
            let randomPlacement = Int(arc4random_uniform(7))
            let brickValue = score * (3 + (score / 25))
            let brick = Brick(value: brickValue, placement: randomPlacement, size: GameScene.brickSize, categoryBitMask: brickCategory, contactTestBitMask: ballCategory, collisionBitMask: ballCategory, mode: mode)
            bricks.append(brick)
            self.addChild(brick.valueLabel)
            self.addChild(brick.brickNode)
        } else if mode != "bombDrop" {
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
                
                let brick = Brick(value: score, placement: randomPlacement, size: GameScene.brickSize, categoryBitMask: brickCategory, contactTestBitMask: ballCategory, collisionBitMask: ballCategory, mode: mode)
                bricks.append(brick)
                self.addChild(brick.valueLabel)
                self.addChild(brick.brickNode)
            }
        }
    }
    
    func addPowerUp() {
        let randomPlacement = Int(arc4random_uniform(7))
        let ballPU = BallPU(placement: randomPlacement, categoryBitMask: powerUpCategory, contactTestBitMask: ballCategory, tileSize: GameScene.brickSize, mode: mode)
        
        powerUps.append(ballPU)
        self.addChild(ballPU.powerUpNode)
        
        //1 in 7 chance for star to spawn
        let isStar = Int(arc4random_uniform(7))
        if isStar == 3 {
            var starPlacement = randomPlacement
            while starPlacement == randomPlacement {
                starPlacement = Int(arc4random_uniform(7))
            }
            let starPU = StarPU(placement: starPlacement, categoryBitMask: powerUpCategory, contactTestBitMask: ballCategory, tileSize: GameScene.brickSize, mode: mode)
            powerUps.append(starPU)
            self.addChild(starPU.powerUpNode)
        }
    }
    
    func givePlayerStar() {
        let defaults = UserDefaults.standard
        let stars = defaults.object(forKey: "stars") as? Int ?? 0
        defaults.set(stars + 1, forKey: "stars")
        starCountLabel.text = "\(stars + 1)"
    }
    
    func addBall() {
        let ball = Ball(image: "", borderColour: .white, fillColour: .white, radius: ballRadius, xPosition: ballX, yPosition: ballY + ballRadius, speed: 20, rotation: ballRotation!, categoryBitMask: ballCategory, contactTestBitMask: brickCategory, collisionBitMask: leftWallCategory | rightWallCategory | roofCategory | bottomCategory | brickCategory, ballNum: self.ballCount)
        
        balls.append(ball)
        self.addChild(ball.node)
        
        self.ballCount! += 1
        self.numBalls = self.maxBallCount - self.ballCount + 1
        
        if numBalls == 1 {
            self.numBallsLabel.isHidden = true
        }
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
        
        if mode == "reversed" {
            self.bottom.strokeColor = SKColor.white
            self.roof.strokeColor = SKColor.init(red: (244/255), green: (75/255), blue: (66/255), alpha: 1.0)
        } else {
            self.bottom.strokeColor = SKColor.init(red: (244/255), green: (75/255), blue: (66/255), alpha: 1.0)
            self.roof.strokeColor = SKColor.white
        }
        
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
                } else if (secondBody.categoryBitMask & powerUpCategory) != 0 {
                    ballDidHitPowerUp(ballNode: firstBody.node as! SKShapeNode, powerUpNode: secondBody.node!)
                } else {
                    //Nothing as of yet
                }
            }
        }
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
                if (wallNode.physicsBody?.categoryBitMask == roofCategory && mode != "reversed") || (wallNode.physicsBody?.categoryBitMask == bottomCategory && mode == "reversed") {
                    //The roof is technically like hitting the bottom of a brick
                    
                    if mode == "reversed" {
                        balls[i].changeYDirection(isTop: true)
                    } else {
                        balls[i].changeYDirection(isTop: false)
                    }
                } else if (wallNode.physicsBody?.categoryBitMask == bottomCategory && mode != "reversed") || (wallNode.physicsBody?.categoryBitMask == roofCategory && mode == "reversed") {
                    
                    if !firstBallEnded {
                        firstBallEnded = true
                        newBallX = ballNode.position.x
                        newPositionMarker.position.x = newBallX
                        newPositionMarker.isHidden = false
                    }
                    
                    //Remove ball if it hits the bottom
                    removeBall(index: i)
                    
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
    
    func ballDidHitPowerUp(ballNode:SKShapeNode, powerUpNode:SKNode) {
        var powerUp:PowerUp!
        var index = 0
        for pU in powerUps {
            if pU.powerUpNode == powerUpNode {
                powerUp = pU
                break
            }
            index += 1
        }
        
        if powerUp != nil {
            switch powerUp.type! {
            case .Ball:
                print("Hit ball")
                self.additionalBalls += 1
                powerUp.removeFromScreen()
                powerUps.remove(at: index)
                break
            case .Star:
                print("Hit star")
                givePlayerStar()
                powerUp.removeFromScreen()
                powerUps.remove(at: index)
                break
            }
        } else {
            print("NIL POWERUP")
        }
    }
    
    func removeBall(index: Int) {
        self.balls[index].node.removeFromParent()
        self.balls.remove(at: index)
    }
    
    func changeLevel() {
        gameState = .changeLevel
        firstBallEnded = false
        ballX = newBallX
        
        //Resets the ball counters and adds any adition balls gained from powerUps
        ballCount = 0
        maxBallCount! += additionalBalls
        additionalBalls = 0
        
        frames = 0
        score += 1
        addPowerUp()
        addBricks()
        moveObjectsDown()
        
        //Gives player a star if score is % 10
        if score % 10 == 0 {
            givePlayerStar()
        }
        
        checkHighScore()
    }
    
    func checkHighScore() {
        let defaults = UserDefaults.standard
        if score > defaults.object(forKey: "\(mode!)HighScore") as? Int ?? 0 {
            defaults.set(score, forKey: "\(mode!)HighScore")
            highscoreLabel.text = "Best: \(score)"
        }
    }
    
    func moveObjectsDown() {
        movePowerUpsDown()
        moveBricksDown()
    }
    
    func movePowerUpsDown() {
        if powerUps.count > 0 {
            for i in (0...powerUps.count - 1).reversed() {
                
                //If powerUp is off of board
                if !powerUps[i].moveDown() {
                    powerUps.remove(at: i)
                }
                
            }
        }
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
        
        setTimerForNextLevel()
    }
    
    func setTimerForNextLevel() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
            //Show the number of balls
            self.numBallsLabel.position.x = self.ballX
            self.numBallsLabel.isHidden = false
            self.numBalls = self.maxBallCount
            
            //Removes newBallPosition marker
            self.newPositionMarker.isHidden = true
            self.addBall()
            
            self.gameState = .checkGameOver
        })
    }
    
    func endGame() {
        
        for child in self.children {
            child.removeFromParent()
        }
        
        bricks.removeAll()
        powerUps.removeAll()
        balls.removeAll()
        self.viewController.transitionToGameOver(score: score)
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
                gameState = .endGame
                endGame()
            } else {
                gameState = .readyToPlay
            }
            
            break
        case .endGame:
            break
        }
    }
    
    override func didFinishUpdate() {
        bricksHit.removeAll()
    }
}
