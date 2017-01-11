//
//  AI.swift
//  PokePuzzler
//
//  Created by Eugene on 12/28/16.
//  Copyright © 2016 Eugene Chinveeraphan. All rights reserved.
//

import UIKit
import SpriteKit

extension GameViewController {
  
  func AIMoves() {
    let speed = self.opponentPokemon.stats["speed"]!
    let skills = self.opponentPokemon.moveset
    
    // Opponent makes 1 match
    
    var yMark: Float = 0
    for skill in skills {
      
      // Opponent passively gains energy based on speed stat
      let type = skill["type"]! as! String
      let energyGain = arc4random_uniform(UInt32(speed / 3.0)) + 2
      self.opponentEnergy[type]! += Int(energyGain)
      
      // Animate Opponent gaining energy
      scene.animateOpponentEnergyGain(opponentPokemon: self.opponentPokemon, energyType: type, energyGain: Int(energyGain), yMark: yMark) {
      }
      yMark += 30.0
      
    }
    
    // Store possible moves
    for skill in skills {
      let cost = skill["cost"]! as! Int
      let type = skill["type"]! as! String
      if self.opponentEnergy[type]! >= cost {
        self.opponentMoves.append(skill)
        self.opponentEnergy[type] = self.opponentEnergy[type]! - cost
      }
    }
    
    // Run AI Moves
    self.runAISkills()
    
  }
  
  func runAISkills() {
    if self.opponentMoveCount >= self.opponentMoves.count || self.opponentMoves.count == 0 {
      // No more moves to run; End of AI Turn
      self.movesLeft = Int(self.myPokemon.stats["turns"]!)
      self.opponentMoves.removeAll()
      self.opponentMoveCount = 0
      
      // Check Status Effects
      if opponentStatusEffects.count > 0 {
        self.healthCheck()
        let statusEffect = opponentStatusEffects[0]
        self.runStatus(statuses: opponentStatusEffects, status: statusEffect, target: self.opponentPokemon, count: 1) {
          self.updateLabels()
          self.myTurn = true
          self.healthCheck()
          self.scene.animateSwitchTurns(myTurn: self.myTurn) {
            self.beginNextTurn()
          }
        }
      } else {
        self.updateLabels()
        self.myTurn = true
        self.healthCheck()
        self.scene.animateSwitchTurns(myTurn: self.myTurn) {
          self.beginNextTurn()
        }
      }
      
    } else {
      // Run the Next SKill
      healthCheck()
      self.myTurn = false
      let skill = self.opponentMoves[self.opponentMoveCount]
      self.opponentMoveCount += 1
      self.scene.animateSkillBanners(skillType: skill["type"]! as! String) {}
      self.scene.animateSkillTextBanner(skillName: skill["name"]! as! String) {
        self.runSkill(skill["id"]! as! Int) { }
      }
      
    }
    
  }
}
