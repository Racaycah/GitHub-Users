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

class ProfileViewModel {
    private(set) var user: User
    
    weak var delegate: ProfileViewModelDelegate?
    
    init(user: User) {
        self.user = user
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
}
