//
//  Cookie.swift
//  PokePuzzler
//
//  Created by Eugene Chinveeraphan on 13/04/16.
//  Copyright © 2016 Eugene Chinveeraphan. All rights reserved.
//

import SpriteKit

// MARK: - CookieType

enum CookieType: Int, CustomStringConvertible {
  case unknown = 0, normal, grass, electric, fire, water, fighting, steel, dark, psychic, poison, fairy, flying, dragon, rock, bug, ground
  
  var spriteName: String {
    let spriteNames = [
      "Normal",
      "Grass",
      "Electric",
      "Fire",
      "Water",
      "Fighting",
      "Steel",
      "Dark",
      "Psychic",
      "Poison",
      "Fairy",
      "Flying",
      "Dragon",
      "Rock",
      "Bug",
      "Ground"]
    
    return spriteNames[rawValue - 1]
  }
  
  var highlightedSpriteName: String {
    return spriteName
  }
  
  var description: String {
    return spriteName
  }
  
  static func random() -> CookieType {
    return CookieType(rawValue: Int(arc4random_uniform(16)) + 1)!
  }
  
  static func getCookieType(cookieTypeName: String) -> CookieType {
    switch cookieTypeName.lowercased() {
    case "normal": return CookieType(rawValue: 1)!
    case "grass": return CookieType(rawValue: 2)!
    case "electric": return CookieType(rawValue: 3)!
    case "fire": return CookieType(rawValue: 4)!
    case "water": return CookieType(rawValue: 5)!
    case "fighting": return CookieType(rawValue: 6)!
    case "steel": return CookieType(rawValue: 7)!
    case "dark": return CookieType(rawValue: 8)!
    case "psychic": return CookieType(rawValue: 9)!
    case "poison": return CookieType(rawValue: 10)!
    case "fairy": return CookieType(rawValue: 11)!
    case "flying": return CookieType(rawValue: 12)!
    case "dragon": return CookieType(rawValue: 13)!
    case "rock": return CookieType(rawValue: 14)!
    case "bug": return CookieType(rawValue: 15)!
    case "ground": return CookieType(rawValue: 16)!
    default: return CookieType.random()
    }
  }
}


// MARK: - Cookie

func ==(lhs: Cookie, rhs: Cookie) -> Bool {
  return lhs.column == rhs.column && lhs.row == rhs.row
}

class Cookie: CustomStringConvertible, Hashable {
  
  var column: Int
  var row: Int
  var cookieType: CookieType
  var sprite: SKSpriteNode?
  
  init(column: Int, row: Int, cookieType: CookieType) {
    self.column = column
    self.row = row
    self.cookieType = cookieType
  }
  
  var description: String {
    return "type:\(cookieType) square:(\(column),\(row))"
  }
  
  var hashValue: Int {
    return row*10 + column
  }
  
}
