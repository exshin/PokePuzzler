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
  
  var battleSuccess: Bool!
  var expEarned: Int!
  var coinsEarned: Int!
  
  // MARK: IBOutlets
  @IBOutlet weak var expEarnedLabel: UILabel!
  @IBOutlet weak var coinsEarnedLabel: UILabel!
  @IBOutlet weak var messageLabel: UILabel!
  
  // MARK: IBActions
  @IBAction func continueButton(sender: AnyObject) {
    let selectScene = storyboard?.instantiateViewController(withIdentifier: "BattleSelectViewController") as! BattleSelectViewController
    self.present(selectScene, animated: true) { }
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
    
    updateLabels()
    
    // set up scene here
    // see: GameViewController.setupLevel()
    
    // Animate level complete (win or lose)
    // Animate coins earned
    
    // Animate exp earned for userPokemon + level up?
    
    // Save coin and experience earned
    
    
  }
  
  func updateLabels() {
    if battleSuccess == true {
      messageLabel.text = "You Won!"
    } else {
      messageLabel.text = "You Lost..."
    }
    expEarnedLabel.text = String(format: "%ld", Int(expEarned))
    coinsEarnedLabel.text = String(format: "%ld", Int(coinsEarned))
  }
  
}


