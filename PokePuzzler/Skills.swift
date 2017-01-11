//
//  Skills.swift
//  CookieCrunch
//
//  Created by Eugene on 12/26/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//


class Skill {
  var myPokemon: Pokemon
  var opponentPokemon: Pokemon
  var level: Level
  var controller: GameViewController
  
  init(level: Level, controller: GameViewController) {
    self.level = level
    self.controller = controller
    self.myPokemon = controller.myPokemon
    self.opponentPokemon = controller.opponentPokemon
  }
  
  func quickAttack() {
    // Pikachu zips across the battlefield dealing damage and destroying 3 random tiles.
    // Power: 35, Cost: 4, Type: Normal
    
    let myAttack = self.myPokemon.stats["attack"]!
    let mySpeed = self.myPokemon.stats["speed"]!
    let opponentDefense = self.opponentPokemon.stats["defense"]!
    
    let multiplier: Float = 35.0 * 0.05
    var dmg = (((myAttack * 0.5) + (mySpeed * 0.5)) * multiplier) - opponentDefense
    if dmg < 1 {
      dmg = 1.0
    }
    
    self.level.removeRandomCookies(3)
    self.controller.opponentCurrentHP += -dmg
  }
}
