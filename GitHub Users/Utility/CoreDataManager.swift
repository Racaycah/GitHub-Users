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
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
        
        return appDelegate.persistentContainer
        } else {
            /* https://www.donnywals.com/setting-up-a-core-data-store-for-unit-tests/ */
            let container = NSPersistentContainer(name: "GitHub_Users")
            
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
            
            container.loadPersistentStores { (storeDescription, error) in
                if let error = error {
                    fatalError("CoreDataManager initialization error: \(error)")
                }
            }
            
            return container
        }
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
    
    var fetchResultsController: NSFetchedResultsController<User>!
    
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
        savingContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        let batchInsertRequest = NSBatchInsertRequest(entityName: "User", objects: users.map { $0.dictionary })
        batchInsertRequest.resultType = .objectIDs
        
        savingContext.performAndWait { [unowned self] in
            do {
                try savingContext.execute(batchInsertRequest)
                
                try self.fetchResultsController.performFetch()
                let newCount = try? self.mainContext.count(for: User.createFetchRequest())
                print("Users saved after: \(newCount ?? 0)")
                
            } catch let error {
                print("Error batch inserting: \(error.localizedDescription)")
            }
        }
    }
    
    func delete(_ user: UserModel) {
        let userRequest = User.createFetchRequest()
        userRequest.predicate = NSPredicate(format: "id == %d", user.id)
        
        if let foundUsers = try? mainContext.fetch(userRequest), foundUsers.count == 1 {
            mainContext.delete(foundUsers.first!)
            try? mainContext.save()
        }
    }
    
    @discardableResult
    func updateUser(atIndex index: IndexPath, withNote note: String) -> User? {
        let user = fetchResultsController.object(at: index)
        user.setValue(note, forKey: "note")
        
        do {
            try mainContext.save()
            print("Saved note for user:\n\(user)")
            return user
        } catch let error {
            print("Couldn't save note for user: \(user)\n\(error.localizedDescription)")
            return nil
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
