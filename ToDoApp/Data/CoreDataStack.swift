//
//  CoreDataStack.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 26.05.2025.
//

import Foundation
import CoreData

final class CoreDataStack: ObservableObject {
    
    static let shared = CoreDataStack()
    
    lazy var viewContext: NSManagedObjectContext = {
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "ToDoAppModel")
        
        container.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        return container
    }()
        
    private init() {}
    
}
