//
//  Pokemon.swift
//  PokePuzzler
//
//  Created by Eugene Chinveeraphan on 12/23/16.
//  Copyright © 2016 Eugene Chinveeraphan. All rights reserved.
//

import SpriteKit

// MARK: - Pokemon

func ==(lhs: Pokemon, rhs: Pokemon) -> Bool {
  return lhs.hashValue == rhs.hashValue
}

class Pokemon: Hashable {
  
  var id = 0
  var name: String
  var stats: Dictionary<String, Float>
  var growth: Dictionary<String, Float>
  var moveset: Array<Dictionary<String, Any>>
  var type: Array<String>
  var sprite: SKSpriteNode?
  var spriteSize: Int
  var filename: String
  var PokemonPosition: PokemonPosition

  // Create a Pokemon by loading it from a file.
  init(filename: String, PokemonPosition: PokemonPosition) {
    let dictionary = Dictionary<String, Any>.loadJSONFromBundle(filename: filename)
 
    // Unpacking
    self.id = dictionary?["id"] as! Int
    self.name = dictionary?["name"] as! String
    self.stats = dictionary?["stats"] as! Dictionary<String, Float>
    self.growth = dictionary?["growth"] as! Dictionary<String, Float>
    self.type = dictionary?["type"] as! Array<String>
    self.filename = filename
    self.PokemonPosition = PokemonPosition
    self.spriteSize = dictionary?["spriteSize"] as! Int
    
    // Load moveset
    let skillDictionary = Dictionary<String, Any>.loadJSONFromBundle(filename: "skills")
    var moveset: Array<Dictionary<String, Any>> = []
    let pokemonSkills: Array<Int> = dictionary?["moves"] as! Array<Int>
    for skillNumber in pokemonSkills {
      moveset.append(skillDictionary?[String(describing: skillNumber)] as! Dictionary<String, Any>)
    }
    self.moveset = moveset 
    
  }
  
  var hashValue: Int {
    return self.id
  }
  
  func calcExpNeeded(currentLevel: Int) -> Int {
    return 100 + Int(pow((Double(20 * currentLevel)), 1.3))
  }
  
}

enum PokemonPosition: CustomStringConvertible {
  case myPokemon
  case opponentPokemon
  
  var description: String {
    switch self {
    case .myPokemon: return "myPokemon"
    case .opponentPokemon: return "opponentPokemon"
    }
  }
}

