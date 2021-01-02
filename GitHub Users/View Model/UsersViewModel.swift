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
            filteredUsers = users
            delegate?.reloadData()
        }
    }
    
    var searchText: String = "" {
        didSet {
            if searchText.isEmpty {
                filteredUsers = users
            } else {
                filteredUsers = users.filter { ($0.name!.lowercased().contains(searchText.lowercased())) || ($0.note?.lowercased().contains(searchText.lowercased()) ?? false) }
            }
        }
    }
    
    var filteredUsers = [User]()

    private func save(newUsers: [User]) {
        let userEntity = NSEntityDescription.entity(forEntityName: "User", in: saveContext)!
        
        newUsers.forEach { user in
            let newUser = User(entity: userEntity, insertInto: saveContext)
            newUser.id = user.id
            newUser.avatarUrl = user.avatarUrl
            newUser.name = user.name
        }
        
        try? saveContext.save()
    }
    
    func loadSavedUsers() {
        do {
            let usersFetchRequest = User.createFetchRequest()
            usersFetchRequest.sortDescriptors = [.init(key: "id", ascending: true)]
            let savedUsers = try usersContext.fetch(usersFetchRequest)
            self.users = savedUsers
            
            if savedUsers.isEmpty {
                getUsers()
            }
        } catch let error {
            print("Error loading users: \(error.localizedDescription)")
        }
    }
    
    func getUsers() {
//        do {
//            // Check if we're calling the function for the first time
//            if users.isEmpty {
//                let usersFetchRequest = User.createFetchRequest()
//                usersFetchRequest.sortDescriptors = [.init(key: "id", ascending: true)]
//                let savedUsers = try usersContext.fetch(usersFetchRequest)
//                self.users = savedUsers
//            }
            
            NetworkManager.shared.request(.users(page: users.isEmpty ? 0 : Int(users.last!.id)), decodingTo: [User].self) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let fetchedUsers):
                    self.users.isEmpty ? self.users = fetchedUsers : self.users.append(contentsOf: fetchedUsers)
                    self.save(newUsers: fetchedUsers)
                case .failure(let error):
                    break
                }
            }
//        } catch let error {
//            print(error.localizedDescription)
//        }
    }
    
    func deleteAllUsers() {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try usersContext.execute(deleteRequest)
            try usersContext.save()
        } catch let error {
            print(error)
        }
    }
    
    func getCell(from collectionView: UICollectionView, indexPath: IndexPath) -> UserCollectionViewCell {
        let userCell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCollectionViewCell.reuseIdentifier, for: indexPath) as! UserCollectionViewCell
        userCell.configureCell(with: filteredUsers[indexPath.item], invertImage: indexPath.item == 0 ? false : indexPath.item.quotientAndRemainder(dividingBy: 4).remainder == 3)
        
        return userCell
        
    }
}
