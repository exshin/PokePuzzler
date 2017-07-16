//
//  UserPokemonData.swift
//  PokePuzzler
//
//  Created by Eugene on 2/4/17.
//  Copyright © 2017 Eugene Chinveeraphan. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class UserPokemonDataController {
  
  var userPokemon: [NSManagedObject] = []
  let entityName = "UserPokemon"
  let levelMaximum = 99
  
  func createUserPokemon(pokemonName: String, level: Int) {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)!
    let pokemon = NSManagedObject(entity: entity, insertInto: managedContext)
    
    // Get Pokemon Stats and Info
    let pokemonData: Pokemon! = Pokemon(filename: pokemonName, PokemonPosition: .collections)
    let pokemonStats = pokemonData.stats
    let pokemonGrowth = pokemonData.growth
    
    // Set Values
    pokemon.setValue(pokemonData.name, forKeyPath: "pokemonName")
    pokemon.setValue(pokemonData.id, forKeyPath: "pokemonId")
    pokemon.setValue(level, forKeyPath: "level")
    pokemon.setValue(true, forKeyPath: "alive")
    
    // Adjust stats for level
    let lvl = Float(level)
    let stats = ["hp", "attack", "defense", "spattack", "spdefense", "speed"]
    for stat in stats {
      let growth = pokemonGrowth[stat]! * lvl
      pokemon.setValue(pokemonStats[stat]! + growth, forKeyPath: stat)
    }
    pokemon.setValue(pokemonStats["turns"], forKeyPath: "turns")
    
    do {
      try managedContext.save()
      userPokemon.append(pokemon)
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }
  
  func getAllUserPokemon() -> [NSManagedObject] {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
    //fetchRequest.predicate = NSPredicate(format: "pokemonName MATCHES %@", pokemonName)
    
    do {
      userPokemon = try managedContext.fetch(fetchRequest)
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    
    print(userPokemon.count)
    return userPokemon
  }
  
  func updateExp(pokemon: NSManagedObject, addExpAmount: Int) {
    let currentExp = pokemon.value(forKeyPath: "currentExp") as! Int
    let neededExp = pokemon.value(forKeyPath: "neededExp") as! Int
    let totalExp = currentExp + addExpAmount
    
    if totalExp > neededExp {
      // Level Up!
      let currentLevel = pokemon.value(forKeyPath: "level") as! Int
      
      if currentLevel < levelMaximum {
        // Set next level
        pokemon.setValue(currentLevel + 1, forKeyPath: "level")
        
        // Set currentExp
        let leftoverExp = totalExp - neededExp
        pokemon.setValue(leftoverExp, forKeyPath: "currentExp")
        
        // Set neededExp for next level
        let name = pokemon.value(forKeyPath: "pokemonName") as! String
        let myPokemon: Pokemon? = Pokemon(filename: name, PokemonPosition: .collections)
        let nextNeededExp = myPokemon?.calcExpNeeded(currentLevel: currentLevel + 1)
        pokemon.setValue(nextNeededExp, forKeyPath: "neededExp")
      }
    } else {
      pokemon.setValue(totalExp, forKeyPath: "currentExp")
    }
    
    do {
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let managedContext = appDelegate.persistentContainer.viewContext
      try managedContext.save()
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }
}
