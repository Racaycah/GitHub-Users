//
//  UsersViewModel.swift
//  GitHub Users
//
//  Created by Ata Doruk on 19.12.2020.
//

import UIKit

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
        }
    }
    
    func getUsers() {
        NetworkManager.shared.request(.users(page: users.isEmpty ? 0 : users.last!.id), decodingTo: [User].self) { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let fetchedUsers):
                self.users.isEmpty ? self.users = fetchedUsers : self.users.append(contentsOf: fetchedUsers)
            case .failure: break
            }
            }
        }
    
    func getCell(from collectionView: UICollectionView, indexPath: IndexPath) -> UserCollectionViewCell {
        let userCell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCollectionViewCell.reuseIdentifier, for: indexPath) as! UserCollectionViewCell
        userCell.configureCell(with: users[indexPath.item], invertImage: indexPath.item == 0 ? false : indexPath.item.quotientAndRemainder(dividingBy: 4).remainder == 3)
        
        return userCell
        
    }
}
