//
//  GameScene.swift
//  PenguinRun
//
//  Created by Matteo Perotta on 11/12/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    
    let scoreLabel = SKLabelNode()
    
    var player: SKSpriteNode = SKSpriteNode(imageNamed: "player")
    
    var score = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func sceneDidLoad() {
        scoreLabel.zPosition = 3
        scoreLabel.position.y = 130
        addChild(scoreLabel)
        
        let background = SKSpriteNode(imageNamed: "background")
        background.zPosition = -1
        addChild(background)
        
        let ground = SKSpriteNode(imageNamed: "ground")
        ground.zPosition = 0
        addChild(ground)
        
        player.position.x = -250
        player.zPosition = 1
        addChild(player)
        
        if let particles = SKEmitterNode(fileNamed: "SnowParticle"){
            particles.position.x = 0
            particles.position.y = 200
            addChild(particles)
        }
        

        self.lastUpdateTime = 0
        
      
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
