//
//  GameScene.swift
//  PenguinRun
//
//  Created by Matteo Perotta on 11/12/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
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
    }
    
    override func sceneDidLoad() {
        scoreLabel.zPosition = 3
        scoreLabel.position.y = 130
        addChild(scoreLabel)
        
        let background = SKSpriteNode(imageNamed: "background")
        background.zPosition = -1
        addChild(background)
        
        let ground = SKSpriteNode(imageNamed: "ground")
        ground.name = "Ground"
       // ground.anchorPoint = .zero
        ground.position.y = -180
        ground.zPosition = 0
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody!.isDynamic = false
        ground.physicsBody!.affectedByGravity = false
        ground.physicsBody!.categoryBitMask = 4
        addChild(ground)
        
        player.position.x = -250
        player.zPosition = 1
        addChild(player)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
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
      
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
       
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
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
