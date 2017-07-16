//
//  GameScene.swift
//  PokePuzzler
//
//  Created by Eugene Chinveeraphan on 13/04/16.
//  Copyright © 2016 Eugene Chinveeraphan. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
  
  // MARK: Properties
  
  // This is marked as ! because it will not initially have a value, but pretty
  // soon after the GameScene is created it will be given a Level object, and
  // from then on it will always have one (it will never be nil again).
  var level: Level!
  
  let TileWidth: CGFloat = 41.0
  let TileHeight: CGFloat = 41.5
  
  let gameLayer = SKNode()
  let cookiesLayer = SKNode()
  let pokemonLayer = SKNode()
  let tilesLayer = SKNode()
  let cropLayer = SKCropNode()
  let maskLayer = SKNode()
  
  // The column and row numbers of the cookie that the player first touched
  // when he started his swipe movement. These are marked ? because they may
  // become nil (meaning no swipe is in progress).
  var swipeFromColumn: Int?
  var swipeFromRow: Int?
  
  // The scene handles touches. If it recognizes that the user makes a swipe,
  // it will call this swipe handler. This is how it communicates back to the
  // ViewController that a swap needs to take place. You could also use a
  // delegate for this.
  var swipeHandler: ((Swap) -> ())?
  
  // Sprite that is drawn on top of the cookie that the player is trying to swap.
  var selectionSprite = SKSpriteNode()
  var scoreLabel: SKLabelNode!
  
  // Pre-load sounds
  let swapSound = SKAction.playSoundFileNamed("Chomp.wav", waitForCompletion: false)
  let invalidSwapSound = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false)
  let matchSound = SKAction.playSoundFileNamed("Ka-Ching.wav", waitForCompletion: false)
  let fallingCookieSound = SKAction.playSoundFileNamed("Scrape.wav", waitForCompletion: false)
  let addCookieSound = SKAction.playSoundFileNamed("Drip.wav", waitForCompletion: false)
  
  
  // MARK: Init
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder) is not used in this app")
  }
  
  override init(size: CGSize) {
    super.init(size: size)
    
    anchorPoint = CGPoint(x: 0.5, y: 0.5)
    
    // Put an image on the background. Because the scene's anchorPoint is
    // (0.5, 0.5), the background image will always be centered on the screen.
    
    let background = SKSpriteNode(imageNamed: "Background3")
    background.size = size
    addChild(background)
    
    // Add a new node that is the container for all other layers on the playing
    // field. This gameLayer is also centered in the screen.
    
    gameLayer.isHidden = true
    addChild(gameLayer)
    
    let layerPosition = CGPoint(x: -165, y: -310)
    
    
//    // The tiles layer represents the shape of the level. It contains a sprite
//    // node for each square that is filled in.
//    tilesLayer.position = layerPosition
//    gameLayer.addChild(tilesLayer)
//    
//    // We use a crop layer to prevent cookies from being drawn across gaps
//    // in the level design.
//    gameLayer.addChild(cropLayer)
//    
//    // The mask layer determines which part of the cookiesLayer is visible.
//    maskLayer.position = layerPosition
//    cropLayer.maskNode = maskLayer
    
    
    // This layer holds the Cookie sprites. The positions of these sprites
    // are relative to the cookiesLayer's bottom-left corner.
    cookiesLayer.position = layerPosition
    gameLayer.addChild(cookiesLayer)
    
    // This layer holds the Pokemon sprites.
    pokemonLayer.position = layerPosition
    gameLayer.addChild(pokemonLayer)
    
    // nil means that these properties have invalid values.
    swipeFromColumn = nil
    swipeFromRow = nil
    
    // Pre-load the label font so prevent delays during game play.
    let _ = SKLabelNode(fontNamed: "GillSans-BoldItalic")
  }
  
  
  // MARK: Level Setup
  
  func addTiles() {
    for row in 0..<NumRows {
      for column in 0..<NumColumns {
        // If there is a tile at this position, then create a new tile
        // sprite and add it to the mask layer.
        if level.tileAt(column: column, row: row) != nil {
          let tileNode = SKSpriteNode(imageNamed: "MaskTile")
          tileNode.size = CGSize(width: TileWidth, height: TileHeight)
          tileNode.position = pointFor(column: column, row: row)
          maskLayer.addChild(tileNode)
        }
      }
    }
    
    // The tile pattern is drawn *in between* the level tiles. That's why
    // there is an extra column and row of them.
    for row in 0...NumRows {
      for column in 0...NumColumns {
        
        let topLeft     = (column > 0) && (row < NumRows)
          && level.tileAt(column: column - 1, row: row) != nil
        let bottomLeft  = (column > 0) && (row > 0)
          && level.tileAt(column: column - 1, row: row - 1) != nil
        let topRight    = (column < NumColumns) && (row < NumRows)
          && level.tileAt(column: column, row: row) != nil
        let bottomRight = (column < NumColumns) && (row > 0)
          && level.tileAt(column: column, row: row - 1) != nil
        
        // The tiles are named from 0 to 15, according to the bitmask that is
        // made by combining these four values.
        let value =
          Int(topLeft.hashValue) |
          Int(topRight.hashValue) << 1 |
          Int(bottomLeft.hashValue) << 2 |
          Int(bottomRight.hashValue) << 3
        
        // Values 0 (no tiles), 6 and 9 (two opposite tiles) are not drawn.
        if value != 0 && value != 6 && value != 9 {
          let name = String(format: "Tile_%ld", value)
          let tileNode = SKSpriteNode(imageNamed: name)
          tileNode.size = CGSize(width: TileWidth, height: TileHeight)
          var point = pointFor(column: column, row: row)
          point.x -= TileWidth/2
          point.y -= TileHeight/2
          tileNode.position = point
          tilesLayer.addChild(tileNode)
        }
      }
    }
  }
  
  func addSprites(for cookies: Set<Cookie>, completion: @escaping () -> ()) {
    for cookie in cookies {
      // Create a new sprite for the cookie and add it to the cookiesLayer.
      let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
      sprite.size = CGSize(width: TileWidth, height: TileHeight)
      sprite.position = pointFor(column: cookie.column, row: cookie.row)
      cookiesLayer.addChild(sprite)
      cookie.sprite = sprite
      
      // Give each cookie sprite a small, random delay. Then fade them in.
      sprite.alpha = 0
      sprite.xScale = 0.5
      sprite.yScale = 0.5
      
      sprite.run(
        SKAction.sequence([
          SKAction.wait(forDuration: 0.1, withRange: 0.2),
          SKAction.group([
            SKAction.fadeIn(withDuration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
            ])
          ]))
    }
    
    cookiesLayer.run(SKAction.wait(forDuration: 0.2), completion: completion)
  }
  
  func removeAllCookieSprites() {
    cookiesLayer.removeAllChildren()
  }
  
  
  // Sprites Logic for Pokemon
  func addPokemonSprites(for pokemons: Set<Pokemon>) {
    for pokemon in pokemons {
      // Create a new sprite for the cookie and add it to the cookiesLayer.
      let sprite = SKSpriteNode(imageNamed: pokemon.filename)
      // TODO - calculate the pokemon locations
      if pokemon.PokemonPosition.description == "myPokemon" {
        sprite.size = CGSize(width: pokemon.spriteSize + 10, height: pokemon.spriteSize + 10)
        sprite.position = CGPoint(x: 82, y: 480)
      } else {
        sprite.size = CGSize(width: pokemon.spriteSize, height: pokemon.spriteSize)
        sprite.position = CGPoint(x: 253, y: 568)
      }
      
      pokemonLayer.addChild(sprite)
      pokemon.sprite = sprite
      
      // Give each cookie sprite a small, random delay. Then fade them in.
      sprite.alpha = 0
      sprite.xScale = 0.5
      sprite.yScale = 0.5
      
      sprite.run(
        SKAction.sequence([
          SKAction.group([
            SKAction.fadeIn(withDuration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
            ])
          ]))
    
    }
  }
  
  // Load Pokemon Info Screens for My Pokemon and Opponent Pokemon
  func addPokemonInfo(for pokemons: Set<Pokemon>) {
    
    // Load Info Sprites
    let myInfoSprite = SKSpriteNode(imageNamed: "MyInfo")
    let opponentInfoSprite = SKSpriteNode(imageNamed: "OpponentInfo")
    
    myInfoSprite.position = CGPoint(x: 223, y: 490)
    opponentInfoSprite.position = CGPoint(x: 132, y: 600)
    
    pokemonLayer.addChild(myInfoSprite)
    pokemonLayer.addChild(opponentInfoSprite)
  
    // Load HP Bars
    for pokemon in pokemons {
      
      let HealthBar = SKSpriteNode(color:SKColor .green, size: CGSize(width: 102, height: 5))
      HealthBar.name = pokemon.PokemonPosition.description
      HealthBar.anchorPoint = CGPoint(x: 0.0, y: 0.0)
      if pokemon.PokemonPosition.description == "myPokemon" {
        HealthBar.position = CGPoint(x: 201, y: 479)
      } else {
        HealthBar.position = CGPoint(x: 98, y: 589)
      }
      
      HealthBar.zPosition = 5
      pokemonLayer.addChild(HealthBar)
    }
    
  }
  
  // Load Moveset and Cost Bars
  func addPokemonMoveset(pokemon: Pokemon, view: UIView) {
    let moveset = pokemon.moveset
    var skillNumber = 0
    for skill in moveset {
      let xValue = 70 + (skillNumber * 100)
      let skillType = skill["type"]! as! String
      let skillName = skill["name"]! as! String

      // Load Skill Type Sprite (Element)
      let skillTypeSprite = SKSpriteNode(imageNamed: skillType)
      skillTypeSprite.position = CGPoint(x: xValue - 16, y: 363)
      skillTypeSprite.size = CGSize(width: 17, height: 17)
      pokemonLayer.addChild(skillTypeSprite)
      
      // Maximum cost bar
      let costBackBar = SKSpriteNode(color:SKColor .white, size: CGSize(width: 70, height: 10))
      costBackBar.anchorPoint = CGPoint(x: 0.0, y: 0.0)
      costBackBar.position = CGPoint(x: xValue - 5, y: 358)
      
      costBackBar.zPosition = 2
      pokemonLayer.addChild(costBackBar)
      
      // Current energy cost bar
      let costBar = SKSpriteNode(color:SKColor .white, size: CGSize(width: 0, height: 10))
      let hexString = self.elementHexString(element: skill["type"]! as! String)
      let color = UIColor(hexString: hexString)
      
      costBar.color = color!
      costBar.anchorPoint = CGPoint(x: 0.0, y: 0.0)
      costBar.position = CGPoint(x: xValue - 5, y: 358)
      costBar.zPosition = 3
      costBar.name = skillName + "CostBar"
      pokemonLayer.addChild(costBar)
      
      skillNumber += 1
    }
  }
  
  // MARK: Point conversion
  
  // Converts a column,row pair into a CGPoint that is relative to the cookieLayer.
  func pointFor(column: Int, row: Int) -> CGPoint {
    return CGPoint(
      x: CGFloat(column)*TileWidth + TileWidth/2,
      y: CGFloat(row)*TileHeight + TileHeight/2)
  }
  
  // Converts a point relative to the cookieLayer into column and row numbers.
  func convertPoint(_ point: CGPoint) -> (success: Bool, column: Int, row: Int) {
    // Is this a valid location within the cookies layer? If yes,
    // calculate the corresponding row and column numbers.
    if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
      point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
      return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
    } else {
      return (false, 0, 0)  // invalid location
    }
  }
  
  
  // MARK: Cookie Swapping
  
  // We get here after the user performs a swipe. This sets in motion a whole
  // chain of events: 1) swap the cookies, 2) remove the matching lines, 3)
  // drop new cookies into the screen, 4) check if they create new matches,
  // and so on.
  func trySwap(horizontal horzDelta: Int, vertical vertDelta: Int) {
    let toColumn = swipeFromColumn! + horzDelta
    let toRow = swipeFromRow! + vertDelta
    
    // Going outside the bounds of the array? This happens when the user swipes
    // over the edge of the grid. We should ignore such swipes.
    guard toColumn >= 0 && toColumn < NumColumns else { return }
    guard toRow >= 0 && toRow < NumRows else { return }
    
    // Can't swap if there is no cookie to swap with. This happens when the user
    // swipes into a gap where there is no tile.
    if let toCookie = level.cookieAt(column: toColumn, row: toRow),
       let fromCookie = level.cookieAt(column: swipeFromColumn!, row: swipeFromRow!),
       let handler = swipeHandler {
         // Communicate this swap request back to the ViewController.
         let swap = Swap(cookieA: fromCookie, cookieB: toCookie)
         handler(swap)
    }
  }
  
  func showSelectionIndicator(for cookie: Cookie) {
    if selectionSprite.parent != nil {
      selectionSprite.removeFromParent()
    }
    
    if let sprite = cookie.sprite {
      let texture = SKTexture(imageNamed: cookie.cookieType.highlightedSpriteName)
      selectionSprite.size = CGSize(width: TileWidth, height: TileHeight)
      selectionSprite.run(SKAction.setTexture(texture))
      
      sprite.addChild(selectionSprite)
      selectionSprite.alpha = 1.0
    }
  }
  
  func hideSelectionIndicator() {
    selectionSprite.run(SKAction.sequence([
      SKAction.fadeOut(withDuration: 0.3),
      SKAction.removeFromParent()]))
  }
  
  // MARK: Cookie Swipe Handlers
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    
    // Convert the touch location to a point relative to the cookiesLayer.
    let location = touch.location(in: cookiesLayer)
    
    // Print coordinates of touch
    // NSLog("X location: %f", location.x)
    // NSLog("Y Location: %f", location.y)
    
    // If the touch is inside a square, then this might be the start of a
    // swipe motion.
    let (success, column, row) = convertPoint(location)
    if success {
      // The touch must be on a cookie, not on an empty tile.
      if let cookie = level.cookieAt(column: column, row: row) {
        // Remember in which column and row the swipe started, so we can compare
        // them later to find the direction of the swipe. This is also the first
        // cookie that will be swapped.
        swipeFromColumn = column
        swipeFromRow = row
        showSelectionIndicator(for: cookie)
      }
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    // If swipeFromColumn is nil then either the swipe began outside
    // the valid area or the game has already swapped the cookies and we need
    // to ignore the rest of the motion.
    guard swipeFromColumn != nil else { return }
    
    guard let touch = touches.first else { return }
    let location = touch.location(in: cookiesLayer)
    
    let (success, column, row) = convertPoint(location)
    if success {
      // Figure out in which direction the player swiped. Diagonal swipes
      // are not allowed.
      var horzDelta = 0, vertDelta = 0
      if column < swipeFromColumn! {          // swipe left
        horzDelta = -1
      } else if column > swipeFromColumn! {   // swipe right
        horzDelta = 1
      } else if row < swipeFromRow! {         // swipe down
        vertDelta = -1
      } else if row > swipeFromRow! {         // swipe up
        vertDelta = 1
      }
      
      // Only try swapping when the user swiped into a new square.
      if horzDelta != 0 || vertDelta != 0 {
        trySwap(horizontal: horzDelta, vertical: vertDelta)
        hideSelectionIndicator()
        
        // Ignore the rest of this swipe motion from now on.
        swipeFromColumn = nil
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    // Remove the selection indicator with a fade-out. We only need to do this
    // when the player didn't actually swipe.
    if selectionSprite.parent != nil && swipeFromColumn != nil {
      hideSelectionIndicator()
    }
    
    // If the gesture ended, regardless of whether if was a valid swipe or not,
    // reset the starting column and row numbers.
    swipeFromColumn = nil
    swipeFromRow = nil
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    touchesEnded(touches, with: event)
  }
  
}
