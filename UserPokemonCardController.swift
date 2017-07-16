//
//  UserPokemonCardController.swift
//  PokePuzzler
//
//  Created by Eugene on 2/5/17.
//  Copyright © 2017 Eugene Chinveeraphan. All rights reserved.
//

import Foundation
import UIKit

class UserPokemonCardController: UICollectionViewCell {
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var level: UILabel!
  
  // MARK: - Properties
  override var isSelected: Bool {
    didSet {
      // imageView.layer.borderWidth = isSelected ? 2 : 0
      backgroundColor = isSelected ? UIColor.lightGray : UIColor.white
    }
  }
  
  
}

