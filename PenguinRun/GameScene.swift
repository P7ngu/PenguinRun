//
//  GameScene.swift
//  PenguinRun
//
//  Created by Matteo Perotta on 11/12/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let cam = SKCameraNode()
    
    var deltaTime: TimeInterval = 0
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    
    let scoreLabel = SKLabelNode()
    
    var gameTimer: Timer?
    var groundTimer: Timer?
    
    var player: SKSpriteNode = SKSpriteNode(imageNamed: "player")
    
    var score = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        self.view?.ignoresSiblingOrder = false
        groundTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(createGround), userInfo: nil, repeats: true)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1.8, target: self, selector: #selector(createIceEnemy), userInfo: nil, repeats: true)
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    func createScore(){
        scoreLabel.zPosition = 3
        scoreLabel.position.y = 130
        score = 0
        addChild(scoreLabel)
        
    }
    
    func createBG(){
        let background = SKSpriteNode(imageNamed: "background")
        background.zPosition = -10
        addChild(background)
    }
    
    func createPlayer() {
        player.position.x = -250
        player.zPosition = 1
        player.name = "Player"
        addChild(player)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.categoryBitMask = 1
    }
    
    func createSnow() {
        if let particles = SKEmitterNode(fileNamed: "SnowParticle"){
            particles.position.x = 0
            particles.position.y = 200
            addChild(particles)
        }
    }
    override func sceneDidLoad() {
        self.camera = cam
        createScore()
        createBG()
        createGround()
        createPlayer()
        createSnow()
        
        physicsWorld.contactDelegate = self
        
        
        self.lastUpdateTime = 0
        
        
    }
    
    @objc func createGround() {
        
        for i in 0 ... 3 {
            let ground = SKSpriteNode(imageNamed: "ground")
            ground.name = "Ground"
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody!.isDynamic = false
            ground.physicsBody!.affectedByGravity = false
            ground.physicsBody!.categoryBitMask = 4
            ground.zPosition = -2
            ground.position = CGPoint(x: (ground.size.width / 5 + (ground.size.width * CGFloat(i))), y: -230)
            addChild(ground)
            
            let moveLeft = SKAction.moveBy(x: -ground.size.width - 500, y: 0, duration: 5)
            let moveReset = SKAction.moveBy(x: ground.size.width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            ground.run(moveForever)
        }
        
    }
    
    @objc func createIceEnemy(){
        let random = GKRandomDistribution(lowestValue: -250, highestValue: 350)
        let spriteEnemy = SKSpriteNode(imageNamed: "enemy")
        spriteEnemy.physicsBody = SKPhysicsBody(texture: spriteEnemy.texture!, size: spriteEnemy.size)
        spriteEnemy.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        spriteEnemy.physicsBody?.linearDamping = 20
        spriteEnemy.physicsBody?.contactTestBitMask = 1 //1 indicates the player, only collide with the player
        spriteEnemy.physicsBody?.categoryBitMask = 0 //so we can ignore their collision with one another.
        spriteEnemy.position = CGPoint(x: random.nextInt(), y: 200)
        spriteEnemy.zPosition = 20
        addChild(spriteEnemy)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    func touchDown(atPoint pos: CGPoint) {
        jump()
    }
    
    func jump() {
        //player.texture = SKTexture(imageNamed: "player_jumping")
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 420))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    func touchUp(atPoint pos: CGPoint) {
        // player?.texture = SKTexture(imageNamed: "player_standing")
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        cam.position = player.position
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
            guard let nodeA = contact.bodyA.node else { return }
            guard let nodeB = contact.bodyB.node else { return }
            if nodeA.name == "Player"{
                playerHit(nodeB)
                print("hit")
            } else {
                playerHit(nodeA)
                print("hit")
            }
        
    }
    
    func playerHit(_ node: SKNode){
        if node.name == "bonus"{
            if player.parent != nil{
                //he's not dead
                score += 5
            }
            node.removeFromParent()
            return
        }
        
        if let particles = SKEmitterNode(fileNamed: "Explosion"){
            particles.position.x = player.position.x
            particles.position.y = player.position.y
            particles.zPosition = 3
            addChild(particles)
        }
        player.removeFromParent()
        
        let gameOver = SKSpriteNode(imageNamed: "gameover")
        gameOver.zPosition = 10
        addChild(gameOver)
        
        //let's wait 2 seconds and then run some new code
        DispatchQueue.main.asyncAfter(deadline: .now()+2){
            //new scene incoming
            if let scene = GameScene(fileNamed: "GameScene"){
                scene.scaleMode = .aspectFill
                //let's present it immediately
                self.view?.presentScene(scene)
            }
        }
    }
    
}
