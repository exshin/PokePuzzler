//
//  CollectionViewController.swift
//  PokePuzzler
//
//  Created by Eugene on 1/1/17.
//  Copyright © 2017 Eugene Chinveeraphan. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation
import CoreData

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  let reuseIdentifier = "pokeCard"
  fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
  fileprivate let itemsPerRow: CGFloat = 3
  
  var scene: CollectionScene!
  var collection: Collection!
  var userPokemon: [NSManagedObject] = []
  
  var tapGestureRecognizer: UITapGestureRecognizer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Start the background music.
    // backgroundMusic?.play()
    
    // Load the User Pokemon
    let userPokemonData = UserPokemonDataController()
    userPokemon = userPokemonData.getAllUserPokemon()
    
    if userPokemon.count < 2 {
      userPokemonData.createUserPokemon(pokemonName: "pikachu", level: 5)
      userPokemonData.createUserPokemon(pokemonName: "charmander", level: 5)
      userPokemon = userPokemonData.getAllUserPokemon()
    }
    
    print(userPokemon[0])
    
  }
  
  // MARK: - UICollectionViewDataSource protocol
  
  // tell the collection view how many cells to make
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return userPokemon.count
  }
  
  // make a cell for each cell index path
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    // get a reference to our storyboard cell
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! UserPokemonCardController
    
    // Use the outlet in our custom class to get a reference to the UILabel in the cell
    let name = userPokemon[indexPath.item].value(forKeyPath: "pokemonName") as? String
    cell.name.text = name
    cell.level.text = "Level " + String(describing: userPokemon[indexPath.item].value(forKeyPath: "level") as! Int)
    cell.imageView.image = UIImage(named: name!.lowercased())!
      
    cell.backgroundColor = UIColor.white
    cell.layer.borderColor = UIColor.black.cgColor
    cell.layer.borderWidth = 1
    cell.layer.cornerRadius = 8
    
    return cell
  }
  
  // MARK: - UICollectionViewDelegate protocol
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // handle tap events
    print("You selected cell #\(indexPath.item)!")
    print(userPokemon[indexPath.item].value(forKeyPath: "pokemonName") as! String)
    print(userPokemon[indexPath.item].value(forKeyPath: "level") as! Int)
  }
  
}
