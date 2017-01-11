//
//  SkillAnimations.swift
//  PokePuzzler
//
//  Created by Eugene on 1/1/17.
//  Copyright © 2017 Eugene Chinveeraphan. All rights reserved.
//

import SpriteKit
import UIKit

extension GameScene {
  // Animate
  
  func animateOnCookies(cookies: Array<Cookie>, spriteName: String, completion: @escaping () -> ()) {
    var delay: Float = 0.5
    for cookie in cookies {
      let centerPosition = CGPoint(x: cookie.sprite!.position.x, y: cookie.sprite!.position.y)
      let sproutSprite = SKSpriteNode(imageNamed: spriteName)
      sproutSprite.position = centerPosition
      sproutSprite.size = CGSize(width: 35, height: 35)
      pokemonLayer.addChild(sproutSprite)
      
      let moveAction = SKAction.move(by: CGVector(dx: 0, dy: 5), duration: 1.0)
      moveAction.timingMode = .easeOut
      delay += 0.05
      sproutSprite.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
    }
    pokemonLayer.run(SKAction.wait(forDuration: TimeInterval(delay)), completion: completion)
  }
  
  func animateSendSpriteAttack(spriteName: String, target: Pokemon, sender: Pokemon, speed: Float, completion: @escaping () -> ()) {
    let targetSprite = target.sprite!
    let senderSprite = sender.sprite!
    
    let senderPosition = CGPoint(
      x: (senderSprite.position.x),
      y: (senderSprite.position.y))
    
    let xDistance = targetSprite.position.x - senderSprite.position.x
    let yDistance = targetSprite.position.y - senderSprite.position.y
    
    let attackSprite = SKSpriteNode(imageNamed: spriteName)
    attackSprite.position = senderPosition
    attackSprite.size = CGSize(width: 100, height: 100)
    pokemonLayer.addChild(attackSprite)
    
    let moveAction = SKAction.move(by: CGVector(dx: xDistance, dy: yDistance), duration: TimeInterval(speed))
    attackSprite.run(
      SKAction.sequence([moveAction, SKAction.removeFromParent()]), completion: completion)
  }
  
  func animatePoisonDamage(target: Pokemon, completion: @escaping () -> ()) {
    let targetSprite = target.sprite!
    let centerPosition = CGPoint(
      x: (targetSprite.position.x),
      y: (targetSprite.position.y + 50))
    
    let attackSprite = SKSpriteNode(imageNamed: "poisonAttack")
    attackSprite.position = centerPosition
    attackSprite.size = CGSize(width: 100, height: 100)
    pokemonLayer.addChild(attackSprite)
    
    let delay = SKAction.wait(forDuration: 0.3)
    let moveAction = SKAction.move(by: CGVector(dx: 0, dy: -50), duration: TimeInterval(1.5))
    attackSprite.run(
      SKAction.sequence([delay, moveAction, SKAction.removeFromParent()]), completion: completion)
  }
  
  func addStatusAnimation(statusName: String, targetPokemon: Pokemon) -> SKSpriteNode {
    var centerPosition = CGPoint(x: 0, y: 0)
    if targetPokemon.PokemonPosition.description == "myPokemon" {
      centerPosition = CGPoint(x: 162, y: 482)
    } else {
      centerPosition = CGPoint(x: 62, y: 593)
    }
    
    let statusSprite = SKSpriteNode(imageNamed: statusName + "Status")
    statusSprite.position = centerPosition
    statusSprite.zPosition = 10
    statusSprite.size = CGSize(width: 27, height: 15)
    pokemonLayer.addChild(statusSprite)
    
    return statusSprite
  }
  
  func animateStorm(spriteName: String, target: Pokemon, number: Int, completion: @escaping () -> ()){
    
    let duration: Float = 2.0 / Float(number)
    for _ in 0...number {
      let stormSprite = SKSpriteNode(imageNamed: spriteName)
      
      let value: Int = 25
      let randomXValue = CGFloat((Int(arc4random_uniform(UInt32(value * 2))) - value) * 5)
      let randomYValue = CGFloat((Int(arc4random_uniform(UInt32(value * 2))) - value) * 5)
      let xValue = target.sprite!.position.x + randomXValue
      let yValue = target.sprite!.position.y + randomYValue
      let moveVector = CGVector(dx: (-randomXValue * 2), dy: (-randomYValue * 2))
      
      let startingPosition = CGPoint(x: xValue, y: yValue)
      stormSprite.position = startingPosition
      stormSprite.size = CGSize(width: 40, height: 40)
      pokemonLayer.addChild(stormSprite)
      
      let moveAction = SKAction.move(by: moveVector, duration: TimeInterval(duration))
      moveAction.timingMode = .easeOut
      let waitAction = SKAction.wait(forDuration: 0.15)
      stormSprite.run(SKAction.sequence([moveAction, waitAction, SKAction.removeFromParent()]))
    }
    pokemonLayer.run(SKAction.wait(forDuration: 0.5), completion: completion)
  }
  
  func animateScratch(target: Pokemon, completion: @escaping () -> ()) {
    
  }
  
}
