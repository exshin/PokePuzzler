//
//  Elements.swift
//  CookieCrunch
//
//  Created by Eugene on 12/24/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

class Elements: Hashable, CustomStringConvertible {
  // The Cookies that are part of this chain.
  var cookies = [Cookie]()
  
  enum ChainType: CustomStringConvertible {
    case horizontal
    case vertical
    
    // Note: add any other shapes you want to detect to this list.
    //case ChainTypeLShape
    //case ChainTypeTShape
    
    var description: String {
      switch self {
      case .horizontal: return "Horizontal"
      case .vertical: return "Vertical"
      }
    }
  }
}

func ==(lhs: Chain, rhs: Chain) -> Bool {
  return lhs.cookies == rhs.cookies
}
