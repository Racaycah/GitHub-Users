//
//  CoreDataManager.swift
//  GitHub Users
//
//  Created by Ata Doruk on 23.01.2021.
//

import UIKit
import CoreData

class CoreDataManager {
    private static var persistentContainer: NSPersistentContainer = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer
    }()
    
    private var mainContext: NSManagedObjectContext = {
        let managedContext = persistentContainer.viewContext
        
        return managedContext
    }()
    
    private func newSaveContext() -> NSManagedObjectContext {
        let saveContext = CoreDataManager.persistentContainer.newBackgroundContext()
        saveContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return saveContext
    }
    
    static let shared = CoreDataManager()
    
    private init() {
        fetchResultsController = NSFetchedResultsController(fetchRequest: User.createFetchRequest(), managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchResultsController.performFetch()
        } catch {
            fatalError("Couldn't fetch saved users")
        }
    }
    
    let fetchResultsController: NSFetchedResultsController<User>!
    
    func getSavedUsers() -> [UserModel] {
        if let savedUsers = fetchResultsController.fetchedObjects {
            return savedUsers.map { UserModel(managedObject: $0) }
        } else {
            print("No users saved")
            return []
        }
    }
    
    func userAt(index: IndexPath) -> UserModel {
        let user = fetchResultsController.object(at: index)
        return UserModel(managedObject: user)
    }
    
    func save(users: [UserModel]) {
        let count = try? mainContext.count(for: User.createFetchRequest())
        print("Users saved before: \(count ?? 0)")
        let savingContext = newSaveContext()
        
        let batchInsertRequest = NSBatchInsertRequest(entityName: "User", objects: users.map { $0.dictionary })
        
        savingContext.performAndWait { [unowned self] in
            do {
                try savingContext.execute(batchInsertRequest)
                
                let newCount = try? self.mainContext.count(for: User.createFetchRequest())
                print("Users saved after: \(newCount ?? 0)")
                try self.fetchResultsController.performFetch()
            } catch let error {
                print("Error batch inserting: \(error.localizedDescription)")
            }
        }
    }
    
    func updateUser(atIndex index: IndexPath, withNote note: String) {
        let user = fetchResultsController.object(at: index)
        user.setValue(note, forKey: "note")
        
        do {
            try mainContext.save()
            print("Saved note for user:\n\(user)")
        } catch let error {
            print("Couldn't save note for user: \(user)\n\(error.localizedDescription)")
        }
    }
    
    func saveImage(_ image: UIImage, forUrl url: URL) {
        let userRequest = User.createFetchRequest()
        userRequest.predicate = NSPredicate(format: "avatarUrl == %@", url.absoluteString)
        
        do {
            let users = try mainContext.fetch(userRequest)
            guard users.count == 1 else {
                print("Faulty data, users: \(users)")
                return
            }
            
            let user = users.first!
            user.setValue(image.pngData(), forKey: "image")
            try mainContext.save()
            print("Set image into CoreData for url: \(url)")
        } catch let error {
            print("Error saving image into CoreData with url: \(url)")
        }
    }
    
    func deleteAllUsers() {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try mainContext.execute(deleteRequest)
            try mainContext.save()
//            try usersContext.execute(deleteRequest)
//            try usersContext.save()
//            try saveContext.execute(deleteRequest)
//            try saveContext.save()
        } catch let error {
            print(error)
        }
    }
}
