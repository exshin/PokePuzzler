//
//  BattleEndViewController.swift
//  PokePuzzler
//
//  Created by Eugene on 1/11/17.
//  Copyright © 2017 Eugene Chinveeraphan. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class BattleEndViewController: UIViewController {
  
  var battleSuccess: Bool = false
  var expEarned: Int = 0
  var coinsEarned: Int = 0
  
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
    
    // set up scene here
    // see: GameViewController.setupLevel()
    
    // Animate level complete (win or lose)
    // Animate coins earned
    
    // Animate exp earned for userPokemon + level up?
    
    // Save coin and experience earned
    
    
  }
  
}


