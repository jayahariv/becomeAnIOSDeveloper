//
//  DataController.swift
//  VirtualTourist
//
//  Created by Jayahari Vavachan on 6/20/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import Foundation
import CoreData

/**
 wrapper class for core data
 
 - important:
    - initialize with a model name
    - call `load()` once before using it.
 */

final class DataController {
    
    // MARK: Properties
    
    private let persistentContainer: NSPersistentContainer
    
    public var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: Initialization Methods
    
    public init(_ name: String) {
        persistentContainer = NSPersistentContainer(name: name)
    }
    
    /**
     this function will load the persistant
     
     - parameters:
        - completion: (optional) completion handler, will get called after successfully loaded the store.
     - important: it will stop the execution if it cannot load database.
     */
    public func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescriptor, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            completion?()
        }
    }
}
