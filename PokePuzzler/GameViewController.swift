//
//  GameViewController.swift
//  PokePuzzler
//
//  Created by Eugene Chinveeraphan on 13/04/16.
//  Copyright (c) 2016 Eugene Chinveeraphan. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation
import CoreData

class GameViewController: UIViewController {
  
  // MARK: Properties
  
  // The scene draws the tiles and cookie sprites, and handles swipes.
  var scene: GameScene!
  
  // The level contains the tiles, the cookies, and most of the gameplay logic.
  // Needs to be ! because it's not set in init() but in viewDidLoad().
  var level: Level!
  var currentLevelNum = 1
  
  var movesLeft = 0
  var myCurrentHP: Float = 0.0
  var opponentCurrentHP: Float = 0.0
  
  var myPokemon: Pokemon!
  var opponentPokemon: Pokemon!
  let skillDictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename: "skills")
  let typingDictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename: "typing")
  
  var myTurn: Bool = true
  var opponentMoves: Array<Dictionary<String, Any>> = []
  var opponentMoveCount: Int = 0
  var myStatusEffects: Array<Dictionary<String, Any>> = []
  var myStatusSprites: Dictionary<String, SKSpriteNode> = [:]
  var opponentStatusEffects: Array<Dictionary<String, Any>> = []
  var opponentStatusSprites: Dictionary<String, SKSpriteNode> = [:]
  
  // Elements
  var elements: [String:Int] = [:]
  var opponentEnergy: [String:Int] = [:]
  
  // Data
  
  
  var tapGestureRecognizer: UITapGestureRecognizer!

  lazy var backgroundMusic: AVAudioPlayer? = {
    guard let url = Bundle.main.url(forResource: "Mining by Moonlight", withExtension: "mp3") else {
      return nil
    }
    do {
      let player = try AVAudioPlayer(contentsOf: url)
      player.numberOfLoops = -1
      return player
    } catch {
      return nil
    }
  }()
  
  
  // MARK: IBOutlets
  @IBOutlet weak var gameOverPanel: UIImageView!
  @IBOutlet weak var movesLeftLabel: UILabel!
  @IBOutlet weak var currentHPLabel: UILabel!
  @IBOutlet weak var currentOpponentHPLabel: UILabel!
  
  @IBOutlet weak var myPokemonName: UILabel!
  @IBOutlet weak var opponentPokemonName: UILabel!
  
  // MARK: IBActions
  
  
  // MARK: View Controller Functions
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return [.portrait, .portraitUpsideDown]
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Setup view with level 1
    setupLevel(currentLevelNum)
    
    // Start the background music.
    // backgroundMusic?.play()
  }
  
  
  // MARK: Game functions
  
  func setupLevel(_ levelNum: Int) {
    let skView = view as! SKView
    skView.isMultipleTouchEnabled = false
    
    // Create and configure the scene.
    scene = GameScene(size: skView.bounds.size)
    scene.scaleMode = .aspectFill
    
    // Setup the level.
    level = Level(filename: "Level_\(levelNum)")
    scene.level = level
    
    // scene.addTiles()
    scene.swipeHandler = handleSwipe
    
    // Setup the Pokemon.
    var pokemonSet = Set<Pokemon>()
    pokemonSet.insert(myPokemon)
    pokemonSet.insert(opponentPokemon)
    scene.addPokemonSprites(for: pokemonSet)
    scene.addPokemonInfo(for: pokemonSet)
    
    // Update Pokemon Names.
    myPokemonName.text = myPokemon.name
    opponentPokemonName.text = opponentPokemon.name
    myCurrentHP = myPokemon.stats["hp"]!
    opponentCurrentHP = opponentPokemon.stats["hp"]!
    
    // Setup moves left
    movesLeft = Int(myPokemon.stats["turns"]!)
    
    // Setup skills buttons
    scene.addPokemonMoveset(pokemon: myPokemon, view: skView)
    self.addPokemonSkillButtons()
    
    gameOverPanel.isHidden = true
    
    // Present the scene.
    skView.presentScene(scene)
    
    // Start the game.
    beginGame()
  }
  
  func beginGame() {
    myTurn = true
    for skill in self.myPokemon.moveset {
      elements[skill["type"] as! String] = 0
    }
    for skill in self.opponentPokemon.moveset {
      opponentEnergy[skill["type"] as! String] = 0
    }
    updateLabels()
    
    scene.animateBeginGame() {
      
    }
    
    shuffle()
  }
  
  func shuffle() {
    scene.removeAllCookieSprites()
    
    // Fill up the level with new cookies, and create sprites for them.
    var energySet: Set<String>
    if level.energySet.count == 0 {
      energySet = Set(Array(self.elements.keys) + Array(self.opponentEnergy.keys))
      repeat {
        energySet.insert(CookieType.random().description)
      } while energySet.count < 6
    } else {
      energySet = Set(level.energySet)
    }
    let newCookies = level.shuffle(energySet: Array(energySet))
    scene.addSprites(for: newCookies) {} 
  }
  
  // This is the swipe handler. MyScene invokes this function whenever it
  // detects that the player performs a swipe.
  func handleSwipe(_ swap: Swap) {
    // While cookies are being matched and new cookies fall down to fill up
    // the holes, we don't want the player to tap on anything.
    view.isUserInteractionEnabled = false
    
    if level.isPossibleSwap(swap) {
      level.performSwap(swap)
      scene.animate(swap: swap) {
        self.handleMatches() { }
      }
      
      // Decrement number of user moves this turn
      decrementMoves()
      
    } else {
      scene.animateInvalidSwap(swap) {
        self.view.isUserInteractionEnabled = true
      }
    }
  }
  
  func beginNextTurn() {
    level.detectPossibleSwaps()
    if level.possibleSwaps.count == 0 {
        shuffle()
    }
    healthCheck()
    view.isUserInteractionEnabled = true
  }
  
  // This is the main loop that removes any matching cookies and fills up the
  // holes with new cookies. While this happens, the user cannot interact with
  // the app.
  func handleMatches(completion: @escaping() -> ()) {
    // Detect if there are any matches left.
    let chains = level.removeMatches()
    
    // If there are no more matches, then the player gets to move again.
    if chains.count == 0 {
      
      if self.myTurn == false {
        // We don't want to trigger beginNextTurn on the opponents turn
        self.runAISkills()
      } else {
        // Else we begin the next player move
        // Check if there are 0 moves left so we can swtich to AI Turn
        turnCheck()
        completion()
      }
    } else {
      // First, remove any matches...
      scene.animateMatchedCookies(for: chains) {
        
        // Calculate match damage, element gain, and animations
        if self.myTurn == true {
          
          
          for chain in chains {
            let elementType = chain.cookieType
            if self.elements[elementType] != nil {
              self.elements[elementType]! += chain.score
            }
            
            // If the chain is a match-5 then gain back 1 move this turn
            let chainType: String = chain.chainType.description
            if chainType == "LShape" || chainType == "TShape" || chain.score > 4 {
              self.movesLeft += 1
              // Animate a match-5 banner with info that the user got an extra turn
              self.scene.animateExtraMoveGain(chain: chain) {}
            }
            
            // Minor Damage for each Match
            let dmg = Float(chain.score) - Float(2)
            
            self.scene.animateDamage(pokemon: self.opponentPokemon, damageValue: Int(dmg)) {
              
            }
            self.opponentCurrentHP += -dmg
            if self.opponentCurrentHP <= 0 {
              self.opponentCurrentHP = 0
            }
            self.updateLabels()
            self.updateHPValue(currentHP: self.opponentCurrentHP, maxHP: self.opponentPokemon.stats["hp"]!, target: "opponentPokemon")
          }
          
          // Update energy values
          for elementType in self.elements.keys {
            if self.elements[elementType] != nil && self.elements[elementType]! > 0 {
              for skill in self.myPokemon.moveset {
                if skill["type"]! as! String == elementType {
                  let cost = skill["cost"]! as! Float
                  let currentElementValue = Float(self.elements[elementType]!)
                  let skillBarName = skill["name"]! as! String + "CostBar"
                  self.updateCostBarValue(energyCurrent: currentElementValue, energyCost: cost, skillBarName: skillBarName)
                }
              }
            }
          }
          
          
        } else {
          for chain in chains {
            let elementType = chain.cookieType
            if self.opponentEnergy[elementType] != nil {
              self.opponentEnergy[elementType]! += chain.score
            }
            
            // Minor Damage for each Match
            let dmg = Float(chain.score) - Float(2)
            self.scene.animateDamage(pokemon: self.myPokemon, damageValue: Int(dmg)) {
              
            }
            self.myCurrentHP += -dmg
            if self.myCurrentHP <= 0 {
              self.myCurrentHP = 0
            }
            self.updateLabels()
            self.updateHPValue(currentHP: self.myCurrentHP, maxHP: self.myPokemon.stats["hp"]!, target: "myPokemon")
          }
        }
        
        self.updateLabels()
        
        // ...then shift down any cookies that have a hole below them...
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
    }
    
  }
  
  func updateLabels() {
    movesLeftLabel.text = String(format: "%ld", movesLeft)
    currentHPLabel.text = String(format: "%ld", Int(myCurrentHP))
    currentOpponentHPLabel.text = String(format: "%ld", Int(opponentCurrentHP))
  }
  
  func updateHPValue(currentHP: Float, maxHP: Float, target: String) {
    // target is either opponentPokemon or myPokemon
    let healthBar = scene.pokemonLayer.childNode(withName: target)!
    let maxCGValue: Float = 102.0
    let oldCGValue: Float = Float(healthBar.frame.size.width)
    let hpPercent: Float = currentHP / maxHP
    let newHPValue = hpPercent * maxCGValue
    let cgDiff = newHPValue - oldCGValue
    
    let reduceHealth = SKAction.resize(byWidth: CGFloat(cgDiff), height: 0, duration: 0.5)
    healthBar.run(reduceHealth)
    if hpPercent <= 0.25 {
      let colorize = SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 1)
      healthBar.run(colorize)
    }
  }
  
  func updateCostBarValue(energyCurrent: Float, energyCost: Float, skillBarName: String) {
    let energyBar = scene.pokemonLayer.childNode(withName: skillBarName)!
    let maxCGValue: Float = 70
    var energyPercent: Float = energyCurrent / energyCost
    if energyPercent > 1.0 {
      energyPercent = 1.0
      // Enough Energy to use skill
      
      // Add border and shadow to button
      // Make the button press animate
      
    } else {
      
      // Remove border and shadow to button
      // Remove the button press animate
    }
    let energyValue = energyPercent * maxCGValue
    let previousCGValue = Float(energyBar.frame.size.width)
    let cgDiff = energyValue - previousCGValue
    let updateEnergyBar = SKAction.resize(byWidth: CGFloat(cgDiff), height: 0, duration: 0.5)
    energyBar.run(updateEnergyBar)
    
  }
  
  func decrementMoves() {
    movesLeft -= 1
    updateLabels()
  }
  
  func healthCheck() {
    if opponentCurrentHP <= 0 {
      // currentLevelNum = currentLevelNum < NumLevels ? currentLevelNum+1 : 1
      showGameOver(status: "win")
    } else if myCurrentHP <= 0 {
      showGameOver(status: "lose")
    }
  }
  
  func turnCheck() {
    if movesLeft == 0 {
      
      // Apply end of my turn status effects
      if myStatusEffects.count > 0 {
        self.healthCheck()
        let statusEffect = myStatusEffects[0]
        self.runStatus(statuses: myStatusEffects, status: statusEffect, target: myPokemon, count: 1) {
          
          // Check health and end game if necessary
          self.healthCheck()
          
          // Set myTurn to false and switch to opponent's turn
          self.myTurn = false
          self.scene.animateSwitchTurns(myTurn: self.myTurn) {
            self.AIMoves()
          }
        }
        
      } else {
        // Check health and end game if necessary
        healthCheck()
        
        // Set myTurn to false and switch to opponent's turn
        self.myTurn = false
        self.scene.animateSwitchTurns(myTurn: self.myTurn) {
          self.AIMoves()
        }
      }
    } else {
      beginNextTurn()
    }
  }
  
  func showGameOver(status: String) {
    let endScene = storyboard?.instantiateViewController(withIdentifier: "BattleEndViewController") as! BattleEndViewController
    if status == "win" {
      endScene.coinsEarned = Int(opponentPokemon.stats["hp"]! * 3) - Int(myPokemon.stats["hp"]!) + 100
      endScene.expEarned = Int(opponentPokemon.stats["hp"]! * 2)
      endScene.battleSuccess = true
    } else {
      endScene.coinsEarned = 0
      endScene.expEarned = 0
      endScene.battleSuccess = false
    }
    
    self.present(endScene, animated: true) { }
    
    
    //gameOverPanel.isHidden = false
    //scene.isUserInteractionEnabled = false
    
//    scene.animateGameOver() {
//      self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideGameOver))
//      self.view.addGestureRecognizer(self.tapGestureRecognizer)
//    }
  }
  
  func hideGameOver() {
    view.removeGestureRecognizer(tapGestureRecognizer)
    tapGestureRecognizer = nil
    
    gameOverPanel.isHidden = true
    scene.isUserInteractionEnabled = true
    
    let selectScene = storyboard?.instantiateViewController(withIdentifier: "BattleSelectViewController") as! BattleSelectViewController
    self.present(selectScene, animated: true) { }
  }
  
}
