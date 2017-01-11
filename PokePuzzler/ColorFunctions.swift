//
//  ColorFunctions.swift
//  PokePuzzler
//
//  Created by Eugene Chinveeraphan on 12/27/16.
//  Copyright © 2016 Eugene Chinveeraphan. All rights reserved.
//

import Foundation
import UIKit

extension GameScene {
  
  func elementHexString(element: String) -> String {
    var colorHexString: String = ""
    switch element {
      case "Normal": colorHexString = "#bf9daa"
      case "Flying": colorHexString = "#82a2b2"
      case "Electric": colorHexString = "#f7d51e"
      case "Steel": colorHexString = "#878787"
      case "Dragon": colorHexString = "#830808"
      case "Dark": colorHexString = "#4d4d4d"
      case "Fire": colorHexString = "#f05500"
      case "Water": colorHexString = "#7fc3ee"
      case "Ice": colorHexString = "#b7edff"
      case "Grass": colorHexString = "#2bb216"
      case "Bug": colorHexString = "#517c59"
      case "Poison": colorHexString = "#691e8b"
      case "Psychic": colorHexString = "#a140ce"
      case "Ghost": colorHexString = "#895a9f"
      case "Fighting": colorHexString = "#ce5637"
      case "Rock": colorHexString = "#986052"
      case "Ground": colorHexString = "#c98371"
      case "Fairy": colorHexString = "#83c0c5"
    default: break
    }

    return colorHexString + "ff"
  }
}
