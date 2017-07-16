//
//  GameSceneAnimations.swift
//  PokePuzzler
//
//  Created by Eugene Chinveeraphan on 12/30/16.
//  Copyright © 2016 Eugene Chinveeraphan. All rights reserved.
//

import SpriteKit

extension GameScene {
  
  // MARK: Animations
  
  func animate(swap: Swap, completion: @escaping () -> ()) {
    let spriteA = swap.cookieA.sprite!
    let spriteB = swap.cookieB.sprite!
    
    spriteA.zPosition = 100
    spriteB.zPosition = 90
    
    let duration: TimeInterval = 0.1
    
    let moveA = SKAction.move(to: spriteB.position, duration: duration)
    moveA.timingMode = .easeOut
    spriteA.run(moveA, completion: completion)
    
    let moveB = SKAction.move(to: spriteA.position, duration: duration)
    moveB.timingMode = .easeOut
    spriteB.run(moveB)
    
    run(swapSound)
  }
  
  func animateInvalidSwap(_ swap: Swap, completion: @escaping () -> ()) {
    let spriteA = swap.cookieA.sprite!
    let spriteB = swap.cookieB.sprite!
    
    spriteA.zPosition = 100
    spriteB.zPosition = 90
    
    let duration: TimeInterval = 0.05
    
    let moveA = SKAction.move(to: spriteB.position, duration: duration)
    moveA.timingMode = .easeOut
    
    let moveB = SKAction.move(to: spriteA.position, duration: duration)
    moveB.timingMode = .easeOut
    
    spriteA.run(SKAction.sequence([moveA, moveB]), completion: completion)
    spriteB.run(SKAction.sequence([moveB, moveA]))
    
    run(invalidSwapSound)
  }
  
  func animateMatchedCookies(for chains: Set<Chain>, completion: @escaping () -> ()) {
    
    var delay: Float = 0.0
    for chain in chains {
      animateScore(for: chain)
      
      for cookie in chain.cookies {
        
        // It may happen that the same Cookie object is part of two chains
        // (L-shape or T-shape match). In that case, its sprite should only be
        // removed once.
        if let sprite = cookie.sprite {
          if sprite.action(forKey: "removing") == nil {
            let scaleAction = SKAction.scale(to: 0.05, duration: 0.1)
            scaleAction.timingMode = .easeOut
            sprite.run(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                       withKey: "removing")
            delay += 0.05
          }
        }
      }
    }
    run(matchSound)
    run(SKAction.wait(forDuration: TimeInterval(delay)), completion: completion)
  }
  
  func animateDestroyedCookies(cookies: Array<Cookie>, completion: @escaping () -> ()) {
    for cookie in cookies {
      if let sprite = cookie.sprite {
        if sprite.action(forKey: "removing") == nil {
          let scaleAction = SKAction.scale(to: 0.05, duration: 0.1)
          scaleAction.timingMode = .easeOut
          sprite.run(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                     withKey: "removing")
        }
      }
    }
    
    run(matchSound)
    run(SKAction.wait(forDuration: 0.15), completion: completion)
  }
  
  func animateFallingCookiesFor(columns: [[Cookie]], completion: @escaping () -> ()) {
    var longestDuration: TimeInterval = 0
    for array in columns {
      for (idx, cookie) in array.enumerated() {
        let newPosition = pointFor(column: cookie.column, row: cookie.row)
        
        // The further away from the hole you are, the bigger the delay
        // on the animation.
        let delay = 0.10 + 0.1*TimeInterval(idx)
        
        let sprite = cookie.sprite!   // sprite always exists at this point
        
        // Calculate duration based on far cookie has to fall (0.1 seconds
        // per tile).
        let duration = TimeInterval(((sprite.position.y - newPosition.y) / TileHeight) * 0.1)
        longestDuration = max(longestDuration, duration + delay)
        
        let moveAction = SKAction.move(to: newPosition, duration: duration)
        moveAction.timingMode = .easeOut
        sprite.run(
          SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.group([moveAction, fallingCookieSound])]))
      }
    }
    
    // Wait until all the cookies have fallen down before we continue.
    run(SKAction.wait(forDuration: longestDuration), completion: completion)
  }
  
  func animateNewCookies(_ columns: [[Cookie]], completion: @escaping () -> ()) {
    // We don't want to continue with the game until all the animations are
    // complete, so we calculate how long the longest animation lasts, and
    // wait that amount before we trigger the completion block.
    var longestDuration: TimeInterval = 0
    
    for array in columns {
      
      // The new sprite should start out just above the first tile in this column.
      // An easy way to find this tile is to look at the row of the first cookie
      // in the array, which is always the top-most one for this column.
      let startRow = array[0].row + 1
      
      for (idx, cookie) in array.enumerated() {
        
        // Create a new sprite for the cookie.
        let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
        sprite.size = CGSize(width: TileWidth, height: TileHeight)
        sprite.position = pointFor(column: cookie.column, row: startRow)
        cookiesLayer.addChild(sprite)
        cookie.sprite = sprite
        
        // Give each cookie that's higher up a longer delay, so they appear to
        // fall after one another.
        let delay = 0.1 + 0.1 * TimeInterval(array.count - idx - 1)
        
        // Calculate duration based on far the cookie has to fall.
        let duration = TimeInterval(startRow - cookie.row) * 0.1
        longestDuration = max(longestDuration, duration + delay)
        
        // Animate the sprite falling down. Also fade it in to make the sprite
        // appear less abruptly.
        let newPosition = pointFor(column: cookie.column, row: cookie.row)
        let moveAction = SKAction.move(to: newPosition, duration: duration)
        moveAction.timingMode = .easeOut
        sprite.alpha = 0
        sprite.run(
          SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.group([
              SKAction.fadeIn(withDuration: 0.05),
              moveAction,
              addCookieSound])
            ]))
      }
    }
    
    // Wait until the animations are done before we continue.
    run(SKAction.wait(forDuration: longestDuration), completion: completion)
  }
  
  func animateScore(for chain: Chain) {
    // Figure out what the midpoint of the chain is.
    let firstSprite = chain.firstCookie().sprite!
    let lastSprite = chain.lastCookie().sprite!
    let centerPosition = CGPoint(
      x: (firstSprite.position.x + lastSprite.position.x)/2,
      y: (firstSprite.position.y + lastSprite.position.y)/2 - 8)
    
    // Add a label for the score that slowly floats up.
    let scoreLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
    scoreLabel.fontSize = CGFloat(Int(15 + (chain.score * 3)))
    scoreLabel.text = "+" + String(chain.score)
    
    scoreLabel.position = centerPosition
    scoreLabel.zPosition = 300
    
    let hexString = self.elementHexString(element: chain.cookieType)
    let color = UIColor(hexString: hexString)
    scoreLabel.fontColor = color
    
    cookiesLayer.addChild(scoreLabel)
    
    let moveAction = SKAction.move(by: CGVector(dx: 0, dy: 30), duration: 1.0)
    moveAction.timingMode = .easeOut
    scoreLabel.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
  }
  
  func animateDamage(pokemon: Pokemon, damageValue: Int, completion: @escaping () -> ()) {
    // Figure out what the midpoint of the chain is.
    let pokemonSprite = pokemon.sprite!
    let centerPosition = CGPoint(
      x: (pokemonSprite.position.x + pokemonSprite.position.x)/2,
      y: (pokemonSprite.position.y + pokemonSprite.position.y)/2 - 8)
    let backPosition = CGPoint(
      x: (pokemonSprite.position.x + pokemonSprite.position.x)/2,
      y: (pokemonSprite.position.y + pokemonSprite.position.y)/2 - 10)
    
    // Add a label for the score that slowly floats up.
    let backgroundLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
    backgroundLabel.fontSize = 45
    backgroundLabel.fontColor = UIColor.black
    backgroundLabel.text = String(format: "%ld", damageValue)
    backgroundLabel.position = backPosition
    pokemonLayer.addChild(backgroundLabel)
    
    let damageLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
    damageLabel.fontSize = 40
    damageLabel.fontColor = UIColor.white
    damageLabel.text = String(format: "%ld", damageValue)
    damageLabel.position = centerPosition
    pokemonLayer.addChild(damageLabel)
    
    let moveAction = SKAction.move(by: CGVector(dx: 0, dy: 30), duration: 1.0)
    moveAction.timingMode = .easeOut
    damageLabel.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]), completion: completion)
    backgroundLabel.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
  }
  
  func animatePokemonAttack(pokemon: Pokemon, opponent: Pokemon, attackTarget: String, completion: @escaping () -> ()) {
    let pokemonSprite = pokemon.sprite!
    let opponentSprite = opponent.sprite!
    
    if attackTarget == "opponentPokemon" {
      // animate my pokemon attacking
      let moveAction1 = SKAction.move(by: CGVector(dx: 35, dy: 10), duration: 0.1)
      let moveAction2 = SKAction.move(by: CGVector(dx: -35, dy: -10), duration: 0.1)
      pokemonSprite.run(SKAction.sequence([moveAction1, moveAction2]))
      
      let delay = SKAction.wait(forDuration: 0.3)
      let moveAction3 = SKAction.move(by: CGVector(dx: -5, dy: 0), duration: 0.05)
      let moveAction4 = SKAction.move(by: CGVector(dx: 5, dy: 0), duration: 0.05)
      let moveAction5 = SKAction.move(by: CGVector(dx: -5, dy: 0), duration: 0.05)
      let moveAction6 = SKAction.move(by: CGVector(dx: 5, dy: 0), duration: 0.05)
      opponentSprite.run(
        SKAction.sequence([delay, moveAction3, moveAction4, moveAction5, moveAction6]), completion: completion)
    } else {
      // animate opponent attacking
      let moveAction1 = SKAction.move(by: CGVector(dx: -35, dy: -10), duration: 0.1)
      let moveAction2 = SKAction.move(by: CGVector(dx: 35, dy: 10), duration: 0.1)
      opponentSprite.run(SKAction.sequence([moveAction1, moveAction2]))
      
      let delay = SKAction.wait(forDuration: 0.3)
      let moveAction3 = SKAction.move(by: CGVector(dx: -5, dy: 0), duration: 0.05)
      let moveAction4 = SKAction.move(by: CGVector(dx: 5, dy: 0), duration: 0.05)
      let moveAction5 = SKAction.move(by: CGVector(dx: -5, dy: 0), duration: 0.05)
      let moveAction6 = SKAction.move(by: CGVector(dx: 5, dy: 0), duration: 0.05)
      pokemonSprite.run(
        SKAction.sequence([delay, moveAction3, moveAction4, moveAction5, moveAction6]), completion: completion)
    }
  }
  
  
  // Animate Skills Banners
  func animateSkillBanners(skillType: String, completion: @escaping () -> ()) {
    let banner = SKSpriteNode(color:SKColor .white, size: CGSize(width: UIScreen.main.bounds.width/2 - 20, height: 27))
    let hexString = self.elementHexString(element: skillType)
    let color = UIColor(hexString: hexString)
    
    banner.color = color!
    banner.anchorPoint = CGPoint(x: 0.0, y: 0.0)
    banner.position = CGPoint(x: 20, y: 530)
    banner.zPosition = 4
    self.pokemonLayer.addChild(banner)
    
    // Animate the banner and text
    let moveAction = SKAction.move(by: CGVector(dx: -20, dy: 0), duration: 0.5)
    let waitAction = SKAction.wait(forDuration: 0.5)
    moveAction.timingMode = .easeOut
    
    banner.run(SKAction.sequence([moveAction, waitAction, SKAction.removeFromParent()]), completion: completion)
  }
  
  func animateSkillTextBanner(skillName: String, completion: @escaping () -> ()) {
    let skillTextLabel = SKLabelNode(fontNamed: "GillSans")
    skillTextLabel.text = skillName
    skillTextLabel.fontColor = UIColor.white
    skillTextLabel.fontSize = 14.0
    skillTextLabel.position = CGPoint(x: 80, y: 536)
    skillTextLabel.zPosition = 10
    self.pokemonLayer.addChild(skillTextLabel)
    
    // Animate the banner and text
    let moveAction = SKAction.move(by: CGVector(dx: -20, dy: 0), duration: 0.5)
    let waitAction = SKAction.wait(forDuration: 0.5)
    moveAction.timingMode = .easeOut
    
    skillTextLabel.run(SKAction.sequence([moveAction, waitAction, SKAction.removeFromParent()]), completion: completion)
  }
  
  func animateOpponentEnergyGain(opponentPokemon: Pokemon, energyType: String, energyGain: Int, yMark: Float, completion: @escaping () -> ()) {
    let pokemonSprite = opponentPokemon.sprite!
    let bannerPosition = CGPoint(
      x: (pokemonSprite.position.x) + 50,
      y: (pokemonSprite.position.y) + 50 - CGFloat(yMark))
    let textPosition = CGPoint(
      x: (pokemonSprite.position.x) + 90,
      y: (pokemonSprite.position.y) + 50 - CGFloat(yMark))
    
    // Add banner
    let banner = SKSpriteNode(color:SKColor .white, size: CGSize(width: UIScreen.main.bounds.width/2, height: 19))
    let hexString = self.elementHexString(element: energyType)
    let color = UIColor(hexString: hexString)
    
    banner.color = color!
    banner.anchorPoint = CGPoint(x: 0.0, y: 0.0)
    banner.position = bannerPosition
    banner.zPosition = 199
    self.pokemonLayer.addChild(banner)
    
    // Add a label for the score that slowly moves left.
    let energyLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
    energyLabel.fontSize = 20
    energyLabel.text = "+" + String(energyGain)
    energyLabel.fontColor = UIColor.white
    
    energyLabel.position = textPosition
    energyLabel.zPosition = 200
    pokemonLayer.addChild(energyLabel)
    
    // Animate the banner and text
    let moveAction = SKAction.move(by: CGVector(dx: -20, dy: 0), duration: 1.5)
    let waitAction = SKAction.wait(forDuration: 1.0)
    banner.run(SKAction.sequence([moveAction, waitAction, SKAction.removeFromParent()]))
    energyLabel.run(SKAction.sequence([moveAction, waitAction, SKAction.removeFromParent()]), completion: completion)
  }
  
  // Animate move +1 for a match-5
  func animateExtraMoveGain(chain: Chain, completion: @escaping () -> ()) {
    let extraMoveLabel = SKLabelNode(fontNamed: "GillSans")
    extraMoveLabel.text = "+ 1"
    extraMoveLabel.fontColor = UIColor.black
    extraMoveLabel.fontSize = 14.0
    extraMoveLabel.position = CGPoint(x: 31, y: 360)
    extraMoveLabel.zPosition = 12
    self.pokemonLayer.addChild(extraMoveLabel)
    
    // Animate the banner and text
    let moveAction = SKAction.move(by: CGVector(dx: 0, dy: 10), duration: 1.0)
    let waitAction = SKAction.wait(forDuration: 0.5)
    moveAction.timingMode = .easeOut
    
    extraMoveLabel.run(SKAction.sequence([moveAction, waitAction, SKAction.removeFromParent()]), completion: completion)
    
    let firstSprite = chain.firstCookie().sprite!
    let lastSprite = chain.lastCookie().sprite!
    let centerPosition = CGPoint(
      x: (firstSprite.position.x + lastSprite.position.x)/2,
      y: (firstSprite.position.y + lastSprite.position.y)/2 - 8)
    let extraMoveMessage = SKLabelNode(fontNamed: "GillSans-BoldItalic")
    extraMoveMessage.text = "Moves Left: +1"
    extraMoveMessage.fontSize = 18
    extraMoveMessage.position = centerPosition
    extraMoveMessage.zPosition = 300
    
    let hexString = self.elementHexString(element: chain.cookieType)
    let color = UIColor(hexString: hexString)
    extraMoveMessage.fontColor = color
    extraMoveMessage.color = UIColor.white
    
    cookiesLayer.addChild(extraMoveMessage)
    
    let moveAction2 = SKAction.move(by: CGVector(dx: 0, dy: 30), duration: 1.0)
    moveAction2.timingMode = .easeOut
    extraMoveMessage.run(SKAction.sequence([waitAction, moveAction2, SKAction.removeFromParent()]))
  }
  
  // Animate Switch Turns
  func animateSwitchTurns(myTurn: Bool, completion: @escaping () -> ()) {
    
    // Set up the switch turns banner
    let banner = SKSpriteNode(color:SKColor .white, size: CGSize(width: UIScreen.main.bounds.width - 20, height: 46))
    let color = UIColor(hexString: "#454545ff")
    banner.color = color!
    banner.anchorPoint = CGPoint(x: 0.0, y: 0.0)
    banner.position = CGPoint(x: 10, y: 165)
    banner.zPosition = 299
    self.cookiesLayer.addChild(banner)
    
    // Set up the text for the switch turns banner
    let switchTurnLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
    if myTurn == true {
      switchTurnLabel.text = "Your Turn"
    } else {
      switchTurnLabel.text = "Opponent's Turn"
    }
    
    switchTurnLabel.fontColor = UIColor.white
    switchTurnLabel.fontSize = 25.0
    switchTurnLabel.position = CGPoint(x: UIScreen.main.bounds.width/2 - 30, y: 177)
    switchTurnLabel.zPosition = 300
    self.cookiesLayer.addChild(switchTurnLabel)
    
    // Animate the banner and text
    let moveAction = SKAction.move(by: CGVector(dx: -20, dy: 0), duration: 0.5)
    let waitAction = SKAction.wait(forDuration: 1.0)
    moveAction.timingMode = .easeOut
    
    banner.run(SKAction.sequence([moveAction, waitAction, SKAction.removeFromParent()]))
    switchTurnLabel.run(SKAction.sequence([moveAction, waitAction, SKAction.removeFromParent()]), completion: completion)
  }
  
  func wait(time: Float, completion: @escaping () -> ()) {
    let waitAction = SKAction.wait(forDuration: TimeInterval(time))
    gameLayer.run(waitAction, completion: completion)
  }
  
  func animateGameOver(_ completion: @escaping () -> ()) {
    let action = SKAction.move(by: CGVector(dx: 0, dy: -size.height), duration: 0.3)
    action.timingMode = .easeIn
    gameLayer.run(action, completion: completion)
  }
  
  func animateBeginGame(_ completion: @escaping () -> ()) {
    gameLayer.isHidden = false
    gameLayer.position = CGPoint(x: 0, y: size.height)
    let action = SKAction.move(by: CGVector(dx: 0, dy: -size.height), duration: 0.3)
    action.timingMode = .easeOut
    gameLayer.run(action, completion: completion)
  }

}
