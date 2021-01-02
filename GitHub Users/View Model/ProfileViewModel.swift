//
//  ProfileViewModel.swift
//  GitHub Users
//
//  Created by Ata Doruk on 26.12.2020.
//

import Foundation

protocol ProfileViewModelDelegate: class {
    func userDetailsFetched(_ user: User)
    func errorOccurred(_ error: Error)
}

protocol EditUserDelegate: class {
    func noteSaved(forUser user: User, inIndex index: IndexPath)
}

class ProfileViewModel {
    private(set) var user: User
    var userIndex: IndexPath
    
    weak var delegate: ProfileViewModelDelegate?
    weak var editDelegate: EditUserDelegate?
    
    init(user: User, index: IndexPath) {
        self.user = user
        self.userIndex = index
    }
    
    func getUserDetails() {
        NetworkManager.shared.request(.user(username: user.name!), decodingTo: User.self) { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.delegate?.userDetailsFetched(user)
            case .failure(let error):
                self.delegate?.errorOccurred(error)
            }
        }
    }
    
    func saveNote(_ note: String) {
        let userFetchRequest = User.createFetchRequest()
        userFetchRequest.predicate = NSPredicate(format: "name == %@", user.name!)
        
        if let users = try? usersContext.fetch(userFetchRequest) {
            if users.count == 1 {
                let user = users[0]
                user.setValue(note, forKey: "note")
                
                self.user = user
                try? usersContext.save()
                editDelegate?.noteSaved(forUser: user, inIndex: userIndex)
            }
        }
    }
}
