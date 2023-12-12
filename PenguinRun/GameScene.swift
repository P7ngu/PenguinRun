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
    
    let ground = SKSpriteNode(imageNamed: "ground")
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    
    let scoreLabel = SKLabelNode()
    
    var gameTimer: Timer?
    
    var player: SKSpriteNode = SKSpriteNode(imageNamed: "player")
    
    var score = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        gameTimer = Timer.scheduledTimer(timeInterval: 1.8, target: self, selector: #selector(createIceEnemy), userInfo: nil, repeats: true)
        
       // setUpBackgrounds()
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    

    
    override func sceneDidLoad() {
        self.camera = cam
        scoreLabel.zPosition = 3
        scoreLabel.position.y = 130
        addChild(scoreLabel)
        
        let background = SKSpriteNode(imageNamed: "background")
        background.zPosition = -1
        addChild(background)
        
       
        ground.name = "Ground"
       // ground.anchorPoint = .zero
        ground.position.y = -200
        ground.zPosition = 0
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody!.isDynamic = false
        ground.physicsBody!.affectedByGravity = false
        ground.physicsBody!.categoryBitMask = 4
        addChild(ground)
        
        player.position.x = -250
        player.zPosition = 1
        addChild(player)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.categoryBitMask = 1
        
        physicsWorld.contactDelegate = self
        
        if let particles = SKEmitterNode(fileNamed: "SnowParticle"){
            particles.position.x = 0
            particles.position.y = 200
            addChild(particles)
        }
        
        self.lastUpdateTime = 0
        
      
    }
    
    @objc func createIceEnemy(){
        let random = GKRandomDistribution(lowestValue: -250, highestValue: 350)
        let spriteEnemy = SKSpriteNode(imageNamed: "enemy")
        spriteEnemy.position = CGPoint(x: random.nextInt(), y: -80)
        spriteEnemy.zPosition = 1
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
        player.physicsBody?.applyImpulse(CGVector(dx: 50, dy: 420))
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

}
