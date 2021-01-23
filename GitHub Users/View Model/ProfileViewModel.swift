//
//  ProfileViewModel.swift
//  GitHub Users
//
//  Created by Ata Doruk on 26.12.2020.
//

import Foundation

protocol ProfileViewModelDelegate: class {
    func userDetailsFetched(_ user: UserModel)
    func errorOccurred(_ error: Error)
}

protocol EditUserDelegate: class {
    func noteSaved(forUser user: UserModel, inIndex index: IndexPath)
}

class ProfileViewModel {
    private(set) var user: UserModel
    var userIndex: IndexPath
    
    weak var delegate: ProfileViewModelDelegate?
    weak var editDelegate: EditUserDelegate?
    
    init(user: UserModel, index: IndexPath) {
        self.user = user
        self.userIndex = index
    }
    
    func getUserDetails() {
        NetworkManager.shared.request(.user(username: user.name), decodingTo: UserModel.self) { [weak self] (result) in
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
        user.note = note
        CoreDataManager.shared.updateUser(atIndex: userIndex, withNote: note)
        editDelegate?.noteSaved(forUser: user, inIndex: userIndex)
    }
}
