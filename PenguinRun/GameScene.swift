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
    var playButton = SKSpriteNode()
    var playButtonIsActive = true
    
    var gameTimer: Timer?
    var groundTimer: Timer?
    var groundDeleteTimer: Timer?
    var gameOver = false
    var touchedPlayButton = false {
        didSet{
            //start the game
            if touchedPlayButton { //the user is starting the game
                playButton.zPosition = -100
                playButtonIsActive = false
                gameTimer = Timer.scheduledTimer(timeInterval: 4.2, target: self, selector: #selector(createIceEnemy), userInfo: nil, repeats: true)
            } else { //I'm resetting it lol
                
               
            }
        }
    }
    
    var player: SKSpriteNode = SKSpriteNode(imageNamed: "player")
    
    var score = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    
    override func didMove(to view: SKView) {
        self.view?.ignoresSiblingOrder = false
        groundTimer = Timer.scheduledTimer(timeInterval: 40, target: self, selector: #selector(createGround), userInfo: nil, repeats: true)
        
        groundDeleteTimer = Timer.scheduledTimer(timeInterval: 1.8, target: self, selector: #selector(deleteUnusedGrounds), userInfo: nil, repeats: true)
        
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
        //player.position.y = -200
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
    
    func createMenu(){
        if gameOver{
            //restart menu
        } else {
            //first time menu
            playButton = SKSpriteNode(imageNamed: "play")
            playButton.zPosition = 70
            playButton.position = CGPoint(x: frame.midX - 250, y: frame.midY - 180)
            self.addChild(playButton)
        }
        
    }
    
    override func sceneDidLoad() {
        createMenu()
        self.camera = cam
        createScore()
        createBG()
        createGround()
        createPlayer()
        createSnow()
        
        physicsWorld.contactDelegate = self
        
        
        self.lastUpdateTime = 0
        
        
    }
    @objc func deleteUnusedGrounds(){
        for node in children {
            if node.position.x < -3000 {
                node.removeFromParent()
            }
        }
    }
    
    @objc func createGround() {
        for i in 0 ... 3 {
            let ground = SKSpriteNode(imageNamed: "ground")
            ground.name = "Ground"
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody!.isDynamic = false
            ground.physicsBody!.affectedByGravity = false
            ground.physicsBody!.categoryBitMask = 2
            ground.zPosition = -2
            ground.position = CGPoint(x: (ground.size.width / 5 + (ground.size.width * CGFloat(i))), y: -240)
            addChild(ground)
            
            let moveLeft = SKAction.moveBy(x: -ground.size.width - 500, y: 0, duration: 15)
            let moveReset = SKAction.moveBy(x: ground.size.width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            ground.run(moveForever)
        }
        
    }
    
    @objc func createIceEnemy(){
        let randomX = GKRandomDistribution(lowestValue: 0, highestValue: 20)
        let randomY = GKRandomDistribution(lowestValue: 0, highestValue: -100)
        
        let spriteEnemy = SKSpriteNode(imageNamed: "enemy")
        spriteEnemy.name = "Enemy"
        spriteEnemy.physicsBody = SKPhysicsBody(texture: spriteEnemy.texture!, size: spriteEnemy.size)
        spriteEnemy.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        spriteEnemy.physicsBody?.linearDamping = 20
        spriteEnemy.physicsBody?.affectedByGravity = false
        spriteEnemy.physicsBody?.contactTestBitMask = 1 | 2 //1 indicates the player, only collide with the player, 2 for the ground
        spriteEnemy.physicsBody?.categoryBitMask = 0 //so we can ignore their collision with one another.
        spriteEnemy.position = CGPoint(x: randomX.nextInt(), y: randomY.nextInt())
        spriteEnemy.zPosition = 20
        addChild(spriteEnemy)
        let moveTheEnemy = SKAction.moveBy(x: -1250, y: 0, duration: 7)
        let moveLoop = SKAction.sequence([moveTheEnemy])
        let moveForever = SKAction.repeatForever(moveLoop)
        spriteEnemy.run(moveForever)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        if tappedNodes.contains(playButton){
            //I'm touching the play button, but is it active?
            if(playButtonIsActive){
                touchedPlayButton.toggle()
            }
        }
    }
    
    func touchDown(atPoint pos: CGPoint) {
        jump()
    }
    
    func jump() {
        if player.position.y < -30 {
            //player.texture = SKTexture(imageNamed: "player_jumping")
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 420))
        }
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
            } else if nodeB.name == "Player"{
                playerHit(nodeA)
                print("hit")
            } else if nodeA.name == "Enemy"{
                cubeHit(nodeA)
                print("hit cube")
            } else if nodeB.name == "Enemy"{
                cubeHit(nodeB)
                print("hit cube")
            }
        
    }
    
    func cubeHit(_ node: SKNode){
        if let particles = SKEmitterNode(fileNamed: "Explosion"){
            print("explosion cube")
            particles.position.x = node.position.x
            particles.position.y = node.position.y
            particles.zPosition = 3
           // addChild(particles)
        }
        //node.removeFromParent()
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
            print("explosion")
            particles.position.x = player.position.x
            particles.position.y = player.position.y
            particles.zPosition = 3
            addChild(particles)
        }
        player.removeFromParent()
        
        let gameOver = SKSpriteNode(imageNamed: "gameover")
        gameOver.position = CGPoint(x: -230, y: -100)
        gameOver.zPosition = 10
        addChild(gameOver)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3){
            //new scene incoming
           
            if let scene = GameScene(fileNamed: "GameScene"){
                scene.scaleMode = .aspectFill
                //let's present it immediately
                self.view?.presentScene(scene)
            }
        }
    }
    
}
