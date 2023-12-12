//
//  TestingStuff.swift
//  PenguinRun
//
//  Created by Matteo Perotta on 12/12/23.
//

import Foundation
import SpriteKit

/*
 func setUpBackgrounds() {
 //add background
 
 for i in 0..<3 {
 // add backgrounds, my images were namely, bg-0.png, bg-1.png, bg-2.png
 let background = SKSpriteNode(imageNamed: "bg-\(i).png")
 background.anchorPoint = CGPoint.zero
 background.position = CGPoint(x: CGFloat(i) * size.width, y: 0.0)
 background.size = self.size
 background.zPosition = -5
 background.name = "Background"
 self.addChild(background)
 
 }
 
 for i in 0..<3 {
 // I have used one ground image, you can use 3
 let ground = SKSpriteNode(imageNamed: "Screen.png")
 ground.anchorPoint = CGPoint(x: 0, y: 0)
 ground.size = CGSize(width: self.size.width, height: ground.size.height)
 ground.position = CGPoint(x: CGFloat(i) * size.width, y: 0)
 ground.zPosition = 1
 ground.name = "ground"
 self.addChild(ground)
 
 }
 }
 
 func updateBackground() {
 self.enumerateChildNodes(withName: "Background") { (node, stop) in
 
 if let back = node as? SKSpriteNode {
 let move = CGPoint(x: CGFloat(-self.backgroundSpeed) * CGFloat(self.deltaTime), y: 0)
 back.position += move
 
 if back.position.x < -back.size.width {
 back.position += CGPoint(x: back.size.width * CGFloat(3), y: 0)
 }
 }
 
 }
 }
 
 func updateGroundMovement() {
 self.enumerateChildNodes(withName: "ground") { (node, stop) in
 
 if let back = node as? SKSpriteNode {
 let move = CGPoint(x: -self.backgroundSpeed * CGFloat(self.deltaTime), y: 0)
 back.position += move
 
 if back.position.x < -back.size.width {
 back.position += CGPoint(x: back.size.width * CGFloat(3), y: 0)
 }
 }
 
 }
 }
 /*
  func alternativeJump(){
  // move up 20
  let jumpUpAction = SKAction.moveBy(x: 30, y: 120, duration: 0.2)
  // move down 20
  let jumpDownAction = SKAction.moveBy(x: 30, y: -120, duration: 0.2)
  // sequence of move yup then down
  let jumpSequence = SKAction.sequence([jumpUpAction, jumpDownAction])
  
  // make player run sequence
  player.run(jumpSequence)
  }
  
  func createGrounds(){
  for i in 0...3{
  let ground = SKSpriteNode(imageNamed: "ground")
  ground.name = "Ground"
  ground.position.y = -180
  ground.zPosition = 0
  ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
  ground.physicsBody!.isDynamic = false
  ground.physicsBody!.affectedByGravity = false
  ground.physicsBody!.categoryBitMask = 4
  
  //ground.size = CGSize(width: (self.scene?.size.width)!, height: 75)
  ground.anchorPoint = CGPoint(x: 0.5, y: 0.5)
  // ground.position = CGPoint(x: CGFloat(i) * ground.size.width, y: -(self.frame.size.height / 2))
  
  self.addChild(ground)
  }
  }
  
  func moveGrounds() {
  self.enumerateChildNodes(withName: "Ground", using: ({
  (node, error) in
  node.position.x -= 2
  
  if node.position.x < -((self.scene?.size.width)!) {
  node.position.x += (self.scene?.size.width)! * 3
  }
  }))
  }
  
  */
 */
