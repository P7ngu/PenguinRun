//
//  GameScene.swift
//  PenguinRun
//
//  Created by Matteo Perotta on 11/12/23.
//

import SpriteKit
import GameplayKit
import SwiftUI

class GameScene: SKScene, SKPhysicsContactDelegate {
    @AppStorage("bestscore", store: UserDefaults(suiteName: "group.matteo.perotta.penguin-run")) var bestScore = 0 {
        didSet{
            updateBestScore()
        }
    }
    
    let cam = SKCameraNode()
    
    var deltaTime: TimeInterval = 0
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    
    let scoreLabel = SKLabelNode()
    let bestScoreLabel = SKLabelNode()
    var playButton = SKSpriteNode()
    var exitButton = SKSpriteNode()
    var playButtonIsActive = true
    var exitButtonIsActive = true
    
    var gameTimer: Timer?
    var groundTimer: Timer?
    var groundDeleteTimer: Timer?
    var gameOver = false
    
    var touchedExitButton = false {
        didSet{
            if(exitButtonIsActive){
                restartScene()
            }
        }
    }
    var touchedPlayButton = false {
        didSet{
            //start the game
            if touchedPlayButton { //the user is starting the game
                playButton.zPosition = -100
                playButtonIsActive = false
                createExitButton()
                exitButtonIsActive = true
                let bonusTimer = Timer.scheduledTimer(timeInterval: 3.7, target: self, selector: #selector(createBonus), userInfo: nil, repeats: true)
                gameTimer = Timer.scheduledTimer(timeInterval: 4.2, target: self, selector: #selector(createIceEnemy), userInfo: nil, repeats: true)
            } else { //I'm resetting it lol
                
                exitButtonIsActive = false
            }
        }
    }
    
    var player: SKSpriteNode = SKSpriteNode(imageNamed: "player")
    
    var score = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    func createBestScoreLabel(){
        bestScoreLabel.text = "Best score: \(bestScore)"
        bestScoreLabel.zPosition = 5
        bestScoreLabel.fontColor = .black
        updateBestScore()
        addChild(bestScoreLabel)
    }
    
    func updateBestScore() {
        bestScoreLabel.position.y = (camera?.position.y)! + 120
        bestScoreLabel.position.x = (camera?.position.x)! - 200
        bestScoreLabel.text = "Best score: \(bestScore)"
        
    }
    
    func restartScene(){
        DispatchQueue.main.asyncAfter(deadline: .now()){
            //new scene incoming
            
            if let scene = GameScene(fileNamed: "GameScene"){
                scene.scaleMode = .aspectFill
                //let's present it immediately
                self.view?.presentScene(scene)
            }
        }
    }
    
    func restartSceneWithDelay(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.3){
            //new scene incoming
            if let scene = GameScene(fileNamed: "GameScene"){
                scene.scaleMode = .aspectFill
                //let's present it immediately
                self.view?.presentScene(scene)
            }
        }
    }
    
    override func didMove(to view: SKView) {
        self.view?.ignoresSiblingOrder = false
        groundTimer = Timer.scheduledTimer(timeInterval: 40, target: self, selector: #selector(createGround), userInfo: nil, repeats: true)
        
        groundDeleteTimer = Timer.scheduledTimer(timeInterval: 1.8, target: self, selector: #selector(deleteUnusedGrounds), userInfo: nil, repeats: true)
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    func updateScoreLabelPosition(){
        scoreLabel.position.y = (camera?.position.y)! + 120
        scoreLabel.position.x = (camera?.position.x)! + 250
    }
    
    func createScore(){
        scoreLabel.zPosition = 3
        scoreLabel.fontColor = .black
        updateScoreLabelPosition()
        score = 0
        addChild(scoreLabel)
        
    }
    
    
    
    func createBG(){
        let background = SKSpriteNode(imageNamed: "background")
        background.zPosition = -10
        background.position.y = 70
        addChild(background)
    }
    
    func createPlayer() {
        player.position.x = -265
        //player.position.y = -200
        player.zPosition = 1
        player.name = "Player"
        addChild(player)
        let playerBody = CGSize(width: player.size.width - 20, height: player.size.height - 15)
        player.physicsBody = SKPhysicsBody(rectangleOf: playerBody)
        player.physicsBody?.categoryBitMask = 1
    }
    
    func createSnow() {
        if let particles = SKEmitterNode(fileNamed: "SnowParticle"){
            particles.position.x = 0
            particles.position.y = 200
            addChild(particles)
        }
    }
    
    func updateExitButtonPosition(){
        exitButton.position = CGPoint(x: (camera?.position.x)! - 330, y: (camera?.position.y)! + 130)
    }
    
    func createExitButton(){
        exitButton = SKSpriteNode(imageNamed: "exit")
        exitButton.zPosition = 100
        updateExitButtonPosition()
        addChild(exitButton)
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
        let music = SKAudioNode(fileNamed: "wind.mp3")
        addChild(music)
        createMenu()
        self.camera = cam
        createScore()
        createBG()
        createGround()
        createPlayer()
        createSnow()
        createBestScoreLabel()
        
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
            let rectWidth = ground.size.width
            let rectHeight = ground.size.height - 65
            let rectangle = CGSize(width: rectWidth, height: rectHeight)
            ground.physicsBody = SKPhysicsBody(rectangleOf: rectangle)
            ground.physicsBody!.isDynamic = false
            ground.physicsBody!.affectedByGravity = false
            ground.physicsBody!.categoryBitMask = 2
            ground.zPosition = -9
            ground.position = CGPoint(x: (ground.size.width / 5 + (ground.size.width * CGFloat(i))), y: -270)
            addChild(ground)
            
            let moveLeft = SKAction.moveBy(x: -ground.size.width - 500, y: 0, duration: 15)
            let moveReset = SKAction.moveBy(x: ground.size.width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            ground.run(moveForever)
        }
        
    }
    
    @objc func createBonus(){
        let randomX = GKRandomDistribution(lowestValue: 120, highestValue: 180).nextInt()
        let randomY = GKRandomDistribution(lowestValue: -5, highestValue: 15).nextInt()
        if randomX % 2 == 0 { //normal fish point, effect = +5 points
            print("Normal Bonus spawned in")
            let sprite = SKSpriteNode(imageNamed: "fish")
            sprite.name = "Bonus"
            assignTheBonusAbility(sprite: sprite, randomX: randomX, randomY: randomY)
        } else { //golden fish, effect = immortality for some seconds
            print("Golden Bonus spawned in")
            let sprite = SKSpriteNode(imageNamed: "goldfish")
            sprite.name = "GoldBonus"
            assignTheBonusAbility(sprite: sprite, randomX: randomX, randomY: randomY)
        } /*else { //extra bonus
            print("Extra Bonus spawned in")
            let sprite = SKSpriteNode(imageNamed: "extrafish")
            sprite.name = "ExtraBonus"
            assignTheBonusAbility(sprite: sprite, randomX: randomX, randomY: randomY)
        }*/
        
    }
    
    func assignTheBonusAbility (sprite: SKSpriteNode, randomX: Int, randomY: Int) {
        //This is the same in every case
        sprite.position = CGPoint(x: randomX, y: randomY)
        sprite.zPosition = 1
        addChild(sprite)
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.linearDamping = 3
        sprite.physicsBody?.affectedByGravity = false
        sprite.physicsBody?.contactTestBitMask = 1 //1 indicates the player, only collide with the player
        sprite.physicsBody?.categoryBitMask = 0 //so we can ignore their collision with one another.
        sprite.physicsBody?.collisionBitMask = 0 //we get notified when the player touches the bonus, but they won't bounch on eachother
        let moveTheFish = SKAction.moveBy(x: -300, y: 0, duration: 5)
        let moveLoop = SKAction.sequence([moveTheFish])
        let moveForever = SKAction.repeatForever(moveLoop)
        sprite.run(moveForever)
        
    }
    
    @objc func createIceEnemy(){
        incrementPlayerScore(points: 1)
        let randomX = GKRandomDistribution(lowestValue: 100, highestValue: 200)
        let spriteEnemy = SKSpriteNode(imageNamed: "enemy")
        spriteEnemy.name = "Enemy"
        let icecubeSize = CGSize(width: spriteEnemy.size.width - 60, height: spriteEnemy.size.height - 40)
        spriteEnemy.physicsBody = SKPhysicsBody(rectangleOf: icecubeSize)
        spriteEnemy.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        spriteEnemy.physicsBody?.linearDamping = 0
        spriteEnemy.physicsBody?.affectedByGravity = false
        spriteEnemy.physicsBody?.contactTestBitMask = 1
        //| 2 //1 indicates the player, only collide with the player, 2 for the ground
        spriteEnemy.physicsBody?.categoryBitMask = 0 //so we can ignore their collision with one another.
        spriteEnemy.position = CGPoint(x: randomX.nextInt(), y: -199)
        spriteEnemy.zPosition = 20
        addChild(spriteEnemy)
        let moveTheEnemy = SKAction.moveBy(x: -300, y: 0, duration: 20)
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
        if tappedNodes.contains(exitButton){
            if(exitButtonIsActive){
                print("exit started")
                restartScene()
            }
        }
    }
    
    func touchDown(atPoint pos: CGPoint) {
        jump()
    }
    
    func jump() {
        if player.position.y < -40 {
            let sound = SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false)
            run(sound)
            //player.texture = SKTexture(imageNamed: "player_jumping")
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 300))
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
        cam.position.x = player.position.x
        cam.position.y = player.position.y + 35
        updateExitButtonPosition()
        updateScoreLabelPosition()
        updateBestScore()
        
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
            //cubeHit(nodeA)
            print("hit cube")
        } else if nodeB.name == "Enemy"{
            //cubeHit(nodeB)
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
    
    func givePlayerImmortalityBonus(){
        player.physicsBody?.categoryBitMask = 0 //it doesn't hit the cubes, but neither the fishes
        player.texture = SKTexture(imageNamed: "pingugold")
        DispatchQueue.main.asyncAfter(deadline: .now() + 15){
            print("Bonus effect is over now")
            self.player.physicsBody?.categoryBitMask = 1 //back to normal
            self.player.texture = SKTexture(imageNamed: "player")
        }
    }
    
    func incrementPlayerScore(points: Int){
        if player.parent != nil{
            //he's not dead
            score += points
        }
    }
    
    func playerHit(_ node: SKNode){
        if node.name == "Bonus"{
            let sound = SKAction.playSoundFileNamed("bonus.wav", waitForCompletion: false)
            run(sound)
            incrementPlayerScore(points: 5)
            node.removeFromParent()
            return
        }
        if node.name == "GoldBonus"{
            let sound = SKAction.playSoundFileNamed("bonus.wav", waitForCompletion: false)
            run(sound)
            givePlayerImmortalityBonus()
            node.removeFromParent()
            return
        }
        let sound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
        run(sound)
        
        if let particles = SKEmitterNode(fileNamed: "Explosion"){
            print("explosion")
            particles.position.x = player.position.x
            particles.position.y = player.position.y
            particles.zPosition = 3
            addChild(particles)
        }
        player.removeFromParent()
        makeTheGameEnd()
        
    }
    
    func makeTheGameEnd () {
        let gameOver = SKSpriteNode(imageNamed: "gameover")
        gameOver.zPosition = 10
        gameOver.position = CGPoint(x: -230, y: -100)
        gameOver.alpha = 0
        let sound = SKAction.playSoundFileNamed("icebreak", waitForCompletion: false)
        run(sound)
        addChild(gameOver)
        
        let waitAction = SKAction.wait(forDuration: 0.2)
        let fadeInAction = SKAction.fadeIn(withDuration: 0.75)
        let sequenceAction = SKAction.sequence([waitAction, fadeInAction])
        
        gameOver.run(sequenceAction)
        
        
        if(score > bestScore){
            print("new best score")
            bestScore = score
        }
        restartSceneWithDelay()
    }
    
}
