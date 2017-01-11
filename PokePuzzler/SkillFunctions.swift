//
//  SkillFunctions.swift
//  PokePuzzler
//
//  Created by Eugene Chinveeraphan on 12/27/16.
//  Copyright © 2016 Eugene Chinveeraphan. All rights reserved.
//
import UIKit

extension GameViewController {
  
  func addPokemonSkillButtons() {
    let moveset = myPokemon.moveset
    var skillNumber = 0
    for skill in moveset {
      let xValue = 70 + (skillNumber * 100)
      let skillName = skill["name"]! as! String
      
      // Load Skill Button
      // Background
      let btn: UIButton = UIButton(frame: CGRect(x: xValue, y: 235, width: 90, height: 35))
      
      let hexString = scene.elementHexString(element: skill["type"]! as! String)
      let color = UIColor(hexString: hexString)
      btn.backgroundColor = color
      
      // Round the corners
      btn.layer.cornerRadius = 5.0
      
      // Add a border
      btn.layer.borderColor = UIColor.darkGray.cgColor
      btn.layer.borderWidth = 0.0
      
      // Add a shadow
      btn.layer.shadowColor = UIColor.darkGray.cgColor
      btn.layer.shadowOpacity = 0.5
      btn.layer.shadowRadius = 2
      btn.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
      
      // Add tap action
      btn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
      // Add Skill Name
      btn.setTitle(skillName, for: .normal)
      btn.setTitleColor(UIColor.white, for: .normal)
      btn.titleLabel!.font =  UIFont(name: "HelveticaNeue", size: 12)
      btn.tag = skill["id"]! as! Int
      view.addSubview(btn)
      
      skillNumber += 1
    }
    
  }
  
  func buttonAction(btn: UIButton!) {
    // Animate button press
    UIView.animate(withDuration: 0.1, animations: {
      btn.frame = CGRect(x: btn.frame.origin.x + 1, y: btn.frame.origin.y + 3, width: btn.frame.size.width, height: btn.frame.size.height)
    })
    UIView.animate(withDuration: 0.1, delay: 0.1, animations: {
      btn.frame = CGRect(x: btn.frame.origin.x - 1, y: btn.frame.origin.y - 3, width: btn.frame.size.width, height: btn.frame.size.height)
    })
    
    // Run Skill
    let skillID = btn.tag
    runSkill(skillID) { }
  }
  
  // Skills Execute
  func runSkill(_ skillID: Int, completion: @escaping() -> Void) {
    view.isUserInteractionEnabled = false
    let data = self.skillDictionary![String(skillID)] as! Dictionary<String, Any>
    let power: Float = data["power"] as! Float
    let cost: Int = data["cost"] as! Int
    let type: String = data["type"] as! String
    let style: String = data["style"] as! String
    let costBarName: String = data["name"] as! String + "CostBar"
    let additionals = data["additional"] as! Array<Dictionary<String, String>>
    var attackTarget: String = "myPokemon"
    var sufficientEnergry: Bool = true
    let animationData: Dictionary<String, Any> = data["animation"] as! Dictionary<String, Any>
    
    if self.myTurn {
      attackTarget = "opponentPokemon"
      if elements[type]! >= cost {
        // Skill can be used. Subtract cost from total element
        elements[type] = elements[type]! - cost
        self.updateCostBarValue(energyCurrent: Float(elements[type]!), energyCost: Float(cost), skillBarName: costBarName)
      } else {
        // Insufficient Energy
        print("Insufficient Energy")
        sufficientEnergry = false
      }
    }
    
    if sufficientEnergry == true {
      
      scene.animatePokemonAttack(pokemon: self.myPokemon, opponent: self.opponentPokemon, attackTarget: attackTarget) {
        if animationData.count > 0 {
          var target: Pokemon
          if attackTarget == "myPokemon" {
            target = self.myPokemon
          } else {
            target = self.opponentPokemon
          }
          
          let name = animationData["name"] as! String
          let options = animationData["options"] as! Dictionary<String, Any>
          switch name {
          case "animateStorm": self.scene.animateStorm(spriteName: options["spriteName"] as! String, target: target, number: options["number"] as! Int) {
            if power > 0 {
              self.calculateDamage(power: power, style: style, type: type, attackTarget: attackTarget)
            }
            
            if additionals.count > 0 {
              // Run the additional functions for the skill
              let currentCount: Int = 1
              let extra = additionals[0]
              self.runAdditional(additionals: additionals, additional: extra["name"]!, argument: extra["arg"]!, currentCount: currentCount) {
                completion()
              }
            } else {
              // No additional methods to run
              self.handleMatches() {
                completion()
              }
            }
            }
          default: break
          }
          
        } else {
          if power > 0 {
            self.calculateDamage(power: power, style: style, type: type, attackTarget: attackTarget)
          }
          
          if additionals.count > 0 {
            // Run the additional functions for the skill
            let currentCount: Int = 1
            let extra = additionals[0]
            self.runAdditional(additionals: additionals, additional: extra["name"]!, argument: extra["arg"]!, currentCount: currentCount) {
              completion()
            }
          } else {
            // No additional methods to run
            self.handleMatches() {
              completion()
            }
          }
        }
        
        
      }
    } else {
      self.handleMatches() {
        completion()
      }
    }
    
  }
  
  // Run the Additional Functions
  func runAdditional(additionals: Array<Dictionary<String, String>>, additional: String, argument: String, currentCount: Int, completion: @escaping() -> ()) {
    
    // Run the given one
    switch additional {
    case "destroyRandomTiles": destroyRandomTiles(Int(argument.components(separatedBy: " ")[0])!, spriteName: argument.components(separatedBy: " ")[1]) {
      if currentCount < additionals.count {
        // Run again if there is more
        let extra = additionals[currentCount]
        self.runAdditional(additionals: additionals, additional: extra["name"]!, argument: extra["arg"]!, currentCount: currentCount + 1) {
          completion()
        }
      } else {
        self.handleMatches() {
          completion()
        }
      }
      }
    case "destroyRandomTileBlock": self.destroyRandomTileBlock(size: Int(argument)!) {
      if currentCount < additionals.count {
        // Run again if there is more
        let extra = additionals[currentCount]
        self.runAdditional(additionals: additionals, additional: extra["name"]!, argument: extra["arg"]!, currentCount: currentCount + 1) {
          completion()
        }
      } else {
        self.handleMatches() {
          completion()
        }
      }
      }
    case "destroyRandomColumn": self.destroyRandomColumn(number: Int(argument)!) {
      if currentCount < additionals.count {
        // Run again if there is more
        let extra = additionals[currentCount]
        self.runAdditional(additionals: additionals, additional: extra["name"]!, argument: extra["arg"]!, currentCount: currentCount + 1) {
          completion()
        }
      } else {
        self.handleMatches() {
          completion()
        }
      }
      }
    case "destroyRandomRow": self.destroyRandomRow(number: Int(argument)!) {
      if currentCount < additionals.count {
        // Run again if there is more
        let extra = additionals[currentCount]
        self.runAdditional(additionals: additionals, additional: extra["name"]!, argument: extra["arg"]!, currentCount: currentCount + 1) {
          completion()
        }
      } else {
        self.handleMatches() {
          completion()
        }
      }
      }
    case "transformRandomTiles": self.transformRandomTiles(type: argument.components(separatedBy: " ")[0], number: Int(argument.components(separatedBy: " ")[1])!) {
      if currentCount < additionals.count {
        // Run again if there is more
        let extra = additionals[currentCount]
        self.runAdditional(additionals: additionals, additional: extra["name"]!, argument: extra["arg"]!, currentCount: currentCount + 1) {
          completion()
        }
      } else {
        self.handleMatches() {
          completion()
        }
      }
      }
    case "addStatus": self.addStatus(statusName: argument.components(separatedBy: " ")[0], turns: Int(argument.components(separatedBy: " ")[1])!) {
      if currentCount < additionals.count {
        // Run again if there is more
        let extra = additionals[currentCount]
        self.runAdditional(additionals: additionals, additional: extra["name"]!, argument: extra["arg"]!, currentCount: currentCount + 1) {
          completion()
        }
      } else {
        self.handleMatches() {
          completion()
        }
      }
      }
    case "shuffleBoard": self.shuffleBoard() {
      if currentCount < additionals.count {
        // Run again if there is more
        let extra = additionals[currentCount]
        self.runAdditional(additionals: additionals, additional: extra["name"]!, argument: extra["arg"]!, currentCount: currentCount + 1) {
          completion()
        }
      } else {
        self.handleMatches() {
          completion()
        }
      }
      }
    default: self.handleMatches() {
      completion()
      }
    }
  }
  
  // Skills Animate Functions
  func destroyRandomTiles(_ number: Int, spriteName: String, completion: @escaping() -> ()) {
    var destroyedTiles: Array<Int> = []
    var cookies: Array<Cookie> = []
    
    for _ in 1...number {
      // Generate random numbers for a random cookie
      // Make sure its not one we've already used
      var column: Int = Int(arc4random_uniform(8))
      var row: Int = Int(arc4random_uniform(8))
      var randomID = (column * 10) + row
      while destroyedTiles.contains(randomID) {
        column = Int(arc4random_uniform(8))
        row = Int(arc4random_uniform(8))
        randomID = (column * 10) + row
      }
      destroyedTiles.append(randomID)
      if let cookie = level.cookieAt(column: column, row: row) {
        cookies.append(cookie)
        self.level.removeCookie(cookie)
      } else {
        return
      }
    }
    
    if spriteName != "" || spriteName == "none" {
      self.scene.animateOnCookies(cookies: cookies, spriteName: spriteName) {
        self.scene.animateDestroyedCookies(cookies: cookies) {
          self.refillDestroyedCookies() {
            completion()
          }
        }
      }
    } else {
      self.scene.animateDestroyedCookies(cookies: cookies) {
        self.refillDestroyedCookies() {
          completion()
        }
      }
    }
   
  }
  
  func destroyRandomColumn(number: Int, completion: @escaping() -> ()) {
    var cookies: Array<Cookie> = []
    var columns: Array<Int> = []
    var column: Int
    
    for _ in 1...number {
      repeat {
        column = Int(arc4random_uniform(8))
      } while columns.contains(column)
      
      columns.append(column)
      for row in 0...7 {
        if let cookie = level.cookieAt(column: column, row: row) {
          self.level.removeCookie(cookie)
          cookies.append(cookie)
        } else {
          return
        }
      }
    }
    
    scene.animateDestroyedCookies(cookies: cookies) {
      self.refillDestroyedCookies() {
        completion()
      }
    }
  }
  
  func destroyRandomRow(number: Int, completion: @escaping() -> ()) {
    var cookies: Array<Cookie> = []
    var rows: Array<Int> = []
    var row: Int
    
    for _ in 1...number {
      repeat {
        row = Int(arc4random_uniform(8))
      } while rows.contains(row)
      
      rows.append(row)
      for column in 0...7 {
        if let cookie = level.cookieAt(column: column, row: row) {
          self.level.removeCookie(cookie)
          cookies.append(cookie)
        } else {
          return
        }
      }
    }
    
    scene.animateDestroyedCookies(cookies: cookies) {
      self.refillDestroyedCookies() {
        completion()
      }
    }
  }
  
  func destroyRandomTileBlock(size: Int, completion: @escaping() -> ()) {
    // size = 2 would be 2x2 block; size = 3 is a 3x3 block
    var cookies: Array<Cookie> = []
    
    // Get column and in for center tile of block
    // We don't want to get a tile on the edge
    // Odds
    let edgeSize = (size - 1) / 2
    let internalSize = 7 - (edgeSize * 2)
    let column: Int = Int(arc4random_uniform(UInt32(internalSize))) + edgeSize
    let row: Int = Int(arc4random_uniform(UInt32(internalSize))) + edgeSize
    // Evens
    
    for rowNumber in row-edgeSize...row+edgeSize  {
      for columnNumber in column-edgeSize...column+edgeSize {
        if let cookie = level.cookieAt(column: columnNumber, row: rowNumber) {
          self.level.removeCookie(cookie)
          cookies.append(cookie)
        } else {
          return
        }
      }
    }
    
    scene.animateDestroyedCookies(cookies: cookies) {
      self.refillDestroyedCookies() {
        completion()
      }
    }
  }
  
  func refillDestroyedCookies(completion: @escaping () -> ()) {
    // shift down any cookies that have a hole below them...
    let columns = self.level.fillHoles()
    self.scene.animateFallingCookiesFor(columns: columns) {
      
      // ...and finally, add new cookies at the top.
      let columns = self.level.topUpCookies()
      self.scene.animateNewCookies(columns) {
        
        // Keep repeating this cycle until there are no more matches.
        self.handleMatches() {
          completion()
        }
      }
    }
    
  }
  
  func transformRandomTiles(type: String, number: Int, completion: @escaping () -> ()) {
    
    var transformedTiles: Array<Int> = []
    var cookies: Array<Cookie> = []
    var set = Set<Cookie>()
    let cookieType: CookieType = CookieType.getCookieType(cookieTypeName: type)
    
    for _ in 1...number {
      // Generate random numbers for a random cookie
      
      // Make sure its not one we've already used
      // Make sure the old cookie is not the type we want to transform
      var column: Int = Int(arc4random_uniform(8))
      var row: Int = Int(arc4random_uniform(8))
      var randomID = (column * 10) + row
      var cookie = level.cookieAt(column: column, row: row)!
      var oldCookieType = cookie.cookieType.description.lowercased()
      repeat {
        column = Int(arc4random_uniform(8))
        row = Int(arc4random_uniform(8))
        randomID = (column * 10) + row
        cookie = level.cookieAt(column: column, row: row)!
        oldCookieType = cookie.cookieType.description.lowercased()
      } while transformedTiles.contains(randomID) || oldCookieType == type
      
      transformedTiles.append(randomID)
      cookies.append(cookie)
      self.level.removeCookie(cookie)
      let newCookie = Cookie(column: column, row: row, cookieType: cookieType)
      self.level.cookies[column, row] = newCookie
      set.insert(newCookie)
      
    }
    
    var spriteName: String
    switch type {
    case "grass": spriteName = "sprout"
    default: spriteName = ""
    }
    
    scene.animateDestroyedCookies(cookies: cookies) {
      self.scene.animateOnCookies(cookies: cookies, spriteName: spriteName) {}
      self.scene.wait(time: 0.5) {
        self.scene.addSprites(for: set) {
          self.scene.wait(time: 1.2) {
            self.handleMatches() {
              completion()
            }
          }
        }
      }
    }
  }
  
  func addStatus(statusName: String, turns: Int, completion: @escaping () -> ()) {
    let newStatus = ["name": statusName, "turns": turns] as [String : Any]
    var targetPokemon: Pokemon
    var senderPokemon: Pokemon
    var addStatusCheck: Bool = true

    if self.myTurn == true {
      targetPokemon = self.opponentPokemon
      senderPokemon = self.myPokemon
      if self.opponentStatusSprites[statusName.lowercased()] != nil {
        // same status exists, so pass
        addStatusCheck = false
      } else {
        self.opponentStatusEffects.append(newStatus)
      }
    } else {
      targetPokemon = self.myPokemon
      senderPokemon = self.opponentPokemon
      if self.myStatusSprites[statusName.lowercased()] != nil {
        // same status exists, so pass
        addStatusCheck = false
      } else {
        self.myStatusEffects.append(newStatus)
      }
    }
    
    if addStatusCheck == true {
      // Animate add status effect (attack)
      let spriteName = statusName.lowercased() + "Attack"
      self.scene.animateSendSpriteAttack(spriteName: spriteName, target: targetPokemon, sender: senderPokemon, speed: 1.5) {
        // Add poison marker on target pokemon
        let sprite = self.scene.addStatusAnimation(statusName: statusName.lowercased(), targetPokemon: targetPokemon)
        
        if self.myTurn == true {
          self.opponentStatusSprites[statusName.lowercased()] = sprite
        } else {
          self.myStatusSprites[statusName.lowercased()] = sprite
        }
        
        completion()
      }
    } else {
      completion()
    }
  }
  
  func runStatus(statuses: Array<Dictionary<String, Any>>, status: Dictionary<String, Any>, target: Pokemon, count: Int, completion: @escaping () -> ()) {
    // Run Status
    let statusName: String = status["name"] as! String
    
    switch statusName {
    case "Poison": runPoison(target: target) {
      // Reduce turn count on status by one and remove it if turn is 0
      self.reduceStatusTurns(target: target, statusName: statusName)
      
      // Check if we need to run next status
      self.checkRunStatus(statuses: statuses, target: target, count: count) {
        completion()
      }
      }
    default: completion()
    }
    
  }
  
  func reduceStatusTurns(target: Pokemon, statusName: String) {
    if target.PokemonPosition.description == "myPokemon" {
      for num in 0...self.myStatusEffects.count - 1 {
        if self.myStatusEffects[num]["name"] as! String == statusName {
          let turn = self.myStatusEffects[num]["turns"] as! Int - 1
          
          // No more status effect. Remove from the list
          if turn == 0 {
            self.myStatusEffects.remove(at: num)
            
            // Also remove the marker from the target
            let sprite = self.myStatusSprites["poison"]
            sprite?.removeFromParent()
            self.myStatusSprites["poison"] = nil
          } else {
            let newStatus: Dictionary<String, Any> = ["name": statusName, "turns": turn]
            self.myStatusEffects[num] = newStatus
          }
          
        }
      }
    } else {
      for num in 0...self.opponentStatusEffects.count - 1 {
        if self.opponentStatusEffects[num]["name"] as! String == statusName {
          let turn = self.opponentStatusEffects[num]["turns"] as! Int - 1
          
          // No more status effect. Remove from the list
          if turn == 0 {
            self.opponentStatusEffects.remove(at: num)
            
            // Also remove the marker from the target
            let sprite = self.opponentStatusSprites["poison"]
            sprite?.removeFromParent()
            self.opponentStatusSprites["poison"] = nil
          } else {
            let newStatus: Dictionary<String, Any> = ["name": statusName, "turns": turn]
            self.opponentStatusEffects[num] = newStatus
          }
        }
      }
    }
  }
  
  func checkRunStatus(statuses: Array<Dictionary<String, Any>>, target: Pokemon, count: Int, completion: @escaping () -> ()) {
    if count < statuses.count {
      let nextCount = count + 1
      let nextStatus = statuses[nextCount]
      runStatus(statuses: statuses, status: nextStatus, target: target, count: nextCount) {
        completion()
      }
    } else {
      completion()
    }
  }
  
  func runPoison(target: Pokemon, completion: @escaping () -> ()) {
    let maxHp = target.stats["hp"]!
    let dmg = maxHp / 8.0
    let attackTarget: String = target.PokemonPosition.description
    
    // Animate Status Effect
    scene.animatePoisonDamage(target: target) {
      // Update HP Values
      if attackTarget == "opponentPokemon" {
        self.opponentCurrentHP += -Float(dmg)
        if self.opponentCurrentHP <= 0 {
          self.opponentCurrentHP = 0
        }
        self.updateHPValue(currentHP: self.opponentCurrentHP, maxHP: maxHp, target: attackTarget)
      } else {
        self.myCurrentHP += -Float(dmg)
        if self.myCurrentHP <= 0 {
          self.myCurrentHP = 0
        }
        self.updateHPValue(currentHP: self.myCurrentHP, maxHP: maxHp, target: attackTarget)
      }
      self.scene.animateDamage(pokemon: target, damageValue: Int(dmg)) {
        self.updateLabels()
        completion()
      }
    }
  }
  
  func shuffleBoard(completion: @escaping () -> ()) {
    self.shuffle()
    self.scene.wait(time: 2.5) {
      completion()
    }
  }

  // Damage
  func calculateDamage(power: Float, style: String, type: String, attackTarget: String) {
    
    var rawDamage: Float = 0.0
    var userPokemon: Pokemon
    var targetPokemon: Pokemon
    
    if attackTarget == "opponentPokemon" {
      userPokemon = self.myPokemon
      targetPokemon = self.opponentPokemon
    } else {
      userPokemon = self.opponentPokemon
      targetPokemon = self.myPokemon
    }
    
    let myAttack = userPokemon.stats["attack"]!
    let mySPAttack = userPokemon.stats["spattack"]!
    let opponentDefense = targetPokemon.stats["defense"]!
    let opponentSPDefense = targetPokemon.stats["spdefense"]!
    let mySpeed = userPokemon.stats["speed"]!
    
    switch style {
    case "attackspeed": rawDamage = ((myAttack * 0.6) + (mySpeed * 0.4)) / opponentDefense
    case "attack": rawDamage = myAttack / opponentDefense
    case "spattack": rawDamage = mySPAttack / opponentSPDefense
    case "spattackspeed": rawDamage = ((mySPAttack * 0.6) + (mySpeed * 0.4)) / opponentSPDefense
    default: break
    }
    
    let rand = arc4random_uniform(25) + 100
    let modifier = Float(rand) / 100.0
    let multiplier: Float = power * 0.2
    var dmg: Int = Int(rawDamage * multiplier * modifier)
    if dmg < 1 {
      dmg = 1
    }
    
    // TODO take typing into account for either x2, x4, or x0.5
    var typeMultiplier: Float = 1.0
    for defendingType in targetPokemon.type {
      switch typingDictionary?[type]![defendingType] as! String {
      case "strong": typeMultiplier = typeMultiplier * 2.0
      case "weak": typeMultiplier = typeMultiplier * 0.5
      case "none": typeMultiplier = typeMultiplier * 0.0
      default: typeMultiplier = typeMultiplier * 1.0
      }
    }
    dmg = Int(Float(dmg) * typeMultiplier)
    
    // Update HP Values
    if attackTarget == "opponentPokemon" {
      self.opponentCurrentHP += -Float(dmg)
      if self.opponentCurrentHP <= 0 {
        self.opponentCurrentHP = 0
      }
      self.updateHPValue(currentHP: self.opponentCurrentHP, maxHP: targetPokemon.stats["hp"]!, target: attackTarget)
    } else {
      self.myCurrentHP += -Float(dmg)
      if self.myCurrentHP <= 0 {
        self.myCurrentHP = 0
      }
      self.updateHPValue(currentHP: self.myCurrentHP, maxHP: targetPokemon.stats["hp"]!, target: attackTarget)
    }
    
    // Animate dmg over opponent's sprite
    scene.animateDamage(pokemon: targetPokemon, damageValue: dmg) { }
    
    self.updateLabels()
    
  }
  
}
