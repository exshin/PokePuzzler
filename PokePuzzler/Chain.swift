//
//  Chain.swift
//  PokePuzzler
//
//  Created by Eugene Chinveeraphan on 14/04/16.
//  Copyright © 2016 Eugene Chinveeraphan. All rights reserved.
//

class Chain: Hashable, CustomStringConvertible {
  // The Cookies that are part of this chain.
  var cookies = [Cookie]()
  
  enum ChainType: CustomStringConvertible {
    case horizontal
    case vertical
    case lshape
    case tshape
    case special
    
    // Note: add any other shapes you want to detect to this list.
    //case ChainTypeLShape
    //case ChainTypeTShape
    
    var description: String {
      switch self {
      case .horizontal: return "Horizontal"
      case .vertical: return "Vertical"
      case .lshape: return "LShape"
      case .tshape: return "TShape"
      case .special: return "Special"
      }
    }
  }
  
  // Whether this chain is horizontal or vertical or special.
  var chainType: ChainType
  
  // How many points this chain is worth.
  var score = 0
  
  init(chainType: ChainType) {
    self.chainType = chainType
  }
  
  func add(cookie: Cookie) {
    cookies.append(cookie)
  }
  
  func firstCookie() -> Cookie {
    return cookies[0]
  }
  
  func lastCookie() -> Cookie {
    return cookies[cookies.count - 1]
  }
  
  var length: Int {
    return cookies.count
  }
  
  var description: String {
    return "type:\(chainType) cookies:\(cookies)"
  }
  
  var hashValue: Int {
    return cookies.reduce (0) { $0.hashValue ^ $1.hashValue }
  }
  
  var cookieType: String {
    return cookies[0].cookieType.spriteName
  }
  
  func containsCookie(cookie: Cookie) -> Bool {
    return cookies.contains(cookie)
  }
  
}

func ==(lhs: Chain, rhs: Chain) -> Bool {
  return lhs.cookies == rhs.cookies
}
