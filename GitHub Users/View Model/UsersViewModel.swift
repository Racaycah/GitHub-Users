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
    
    init() {}
    
    weak var delegate: UsersViewModelDelegate?
    
    var users: [UserModel] = [] {
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
                filteredUsers = users.filter { ($0.name.lowercased().contains(searchText.lowercased())) || ($0.note?.lowercased().contains(searchText.lowercased()) ?? false) }
            }
        }
    }
    
    var filteredUsers = [UserModel]()
    
    func loadSavedUsers() {
        self.users = CoreDataManager.shared.getSavedUsers()
            
        if users.isEmpty {
            getUsers()
        }
    }
    
    func getUsers() {
        NetworkManager.shared.request(.users(page: users.isEmpty ? 0 : Int(users.last!.id)), decodingTo: [UserModel].self) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let fetchedUsers):
                self.users.isEmpty ? self.users = fetchedUsers : self.users.append(contentsOf: fetchedUsers)
                CoreDataManager.shared.save(users: fetchedUsers)
            case .failure(let error):
                break
            }
        }
    }
    
    func deleteAllUsers() {
        CoreDataManager.shared.deleteAllUsers()
    }
    
    func getCell(from collectionView: UICollectionView, indexPath: IndexPath) -> UserCollectionViewCell {
        let userCell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCollectionViewCell.reuseIdentifier, for: indexPath) as! UserCollectionViewCell
        userCell.configureCell(with: filteredUsers[indexPath.item], invertImage: indexPath.item == 0 ? false : indexPath.item.quotientAndRemainder(dividingBy: 4).remainder == 3)
        
        return userCell
        
    }
}
