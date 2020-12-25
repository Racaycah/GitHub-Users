//
//  UsersViewModel.swift
//  GitHub Users
//
//  Created by Ata Doruk on 19.12.2020.
//

import UIKit
import CoreData

protocol UsersViewModelDelegate: class {
    func reloadData()
}

class UsersViewModel: BaseCellViewModel {
    typealias Model = User
    typealias Cell = UserCollectionViewCell
    
    weak var delegate: UsersViewModelDelegate?
    
    var users: [User] = [] {
        didSet {
            delegate?.reloadData()
            save(users: users)
        }
    }
    
    private var usersContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.persistentContainer.viewContext
        return managedContext
    }()
    
    private var saveContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let saveContext = appDelegate.persistentContainer.newBackgroundContext()
        return saveContext
    }()
    
    private func save(users: [User]) {
        let userEntity = NSEntityDescription.entity(forEntityName: "User", in: saveContext)!
        
        users.forEach { user in
            let newUser = User(entity: userEntity, insertInto: saveContext)
            newUser.id = user.id
            newUser.avatarUrl = user.avatarUrl
            newUser.name = user.name
        }
        
        try? saveContext.save()
    }
    
    func getUsers() {
        do {
            if users.isEmpty {
                let usersFetchRequest = User.createFetchRequest()
                usersFetchRequest.sortDescriptors = [.init(key: "id", ascending: true)]
                let savedUsers = try usersContext.fetch(usersFetchRequest)
                self.users = savedUsers
            }
            
            NetworkManager.shared.request(.users(page: users.isEmpty ? 0 : Int(users.last!.id)), decodingTo: [User].self) { [weak self] (result) in
                guard let self = self else { return }
                
                switch result {
                case .success(let fetchedUsers):
                    self.users.isEmpty ? self.users = fetchedUsers : self.users.append(contentsOf: fetchedUsers)
                    self.save(users: self.users)
                case .failure: break
                }
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func getCell(from collectionView: UICollectionView, indexPath: IndexPath) -> UserCollectionViewCell {
        let userCell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCollectionViewCell.reuseIdentifier, for: indexPath) as! UserCollectionViewCell
        userCell.configureCell(with: users[indexPath.item], invertImage: indexPath.item == 0 ? false : indexPath.item.quotientAndRemainder(dividingBy: 4).remainder == 3)
        
        return userCell
        
    }
}
