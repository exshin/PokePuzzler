//
//  DataFunctions.swift
//  PokePuzzler
//
//  Created by Eugene on 2/1/17.
//  Copyright © 2017 Eugene Chinveeraphan. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class UsersDataController {
  
  var users: [NSManagedObject] = []
  
  func createUser() {
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Users")
    do {
      users = try managedContext.fetch(fetchRequest)
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    if users.count > 1 {
      return
    }
    
    let entity = NSEntityDescription.entity(forEntityName: "Users", in: managedContext)!
    let person = NSManagedObject(entity: entity, insertInto: managedContext)
    
    person.setValue("TestUser", forKeyPath: "name")
    person.setValue(0, forKeyPath: "coins")
    
    do {
      try managedContext.save()
      users.append(person)
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }
  
  func getUser() -> NSManagedObject {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Users")
    
    do {
      users = try managedContext.fetch(fetchRequest)
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    
    print(users.count)
    return users[0]
    
  }
  
}
