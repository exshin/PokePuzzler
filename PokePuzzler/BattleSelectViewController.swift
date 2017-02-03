//
//  BattleSelectViewController.swift
//  PokePuzzler
//
//  Created by Eugene on 1/1/17.
//  Copyright © 2017 Eugene Chinveeraphan. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation
import CoreData

class BattleSelectViewController: UIViewController, UIPickerViewDelegate {
  
  var pokemonOptions = ["Pikachu", "Charmander", "Squirtle", "Bulbasaur", "Onix", "Butterfree", "Charmeleon", "Charizard"]
  var myPokemon: Pokemon? = Pokemon(filename: "pikachu", PokemonPosition: .myPokemon)
  var opponentPokemon: Pokemon? = Pokemon(filename: "pikachu", PokemonPosition: .opponentPokemon)
  
  @IBOutlet weak var myPokemonPicker: UIPickerView!
  @IBOutlet weak var opponentPokemonPicker: UIPickerView!
  @IBAction func fightButton(sender: AnyObject) {
    let battleScene = storyboard?.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
    battleScene.myPokemon = self.myPokemon
    battleScene.opponentPokemon = self.opponentPokemon
    if battleScene.myPokemon != battleScene.opponentPokemon {
      self.present(battleScene, animated: true) { }
    }
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return [.portrait, .portraitUpsideDown]
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.myPokemonPicker.delegate = self
    self.opponentPokemonPicker.delegate = self
    
    // set up scene here
    // see: GameViewController.setupLevel()
  }
  
  // Picker Functions
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    // Column count: use one column.
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView,
                  numberOfRowsInComponent component: Int) -> Int {
    
    // Row count: rows equals array length.
    return pokemonOptions.count
    
  }
  
  func pickerView(_ pickerView: UIPickerView,
                  titleForRow row: Int,
                  forComponent component: Int) -> String? {
    
    // Return a string from the array for this row.
    return pokemonOptions[row]
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    // Do something with the row
    let name = pokemonOptions[row].lowercased()
    if pickerView == myPokemonPicker {
      self.myPokemon = Pokemon(filename: name, PokemonPosition: .myPokemon)
    } else if pickerView == opponentPokemonPicker {
      self.opponentPokemon = Pokemon(filename: name, PokemonPosition: .opponentPokemon)
    }
  }
  
  
}

