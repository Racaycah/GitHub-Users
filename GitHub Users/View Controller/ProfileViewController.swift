//
//  ProfileViewController.swift
//  GitHub Users
//
//  Created by Ata Doruk on 26.12.2020.
//

import UIKit

class ProfileViewController: BaseViewController {
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    
    var profileViewModel: ProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileViewModel.delegate = self
        profileViewModel.getUserDetails()
    }
}

extension ProfileViewController: ProfileViewModelDelegate {
    func userDetailsFetched(_ user: User) {
        ImageCache.shared.fetch(from: user.avatarUrl!, completion: { [unowned self] (image) in
            self.userAvatarImageView.image = image
        })
        
        NetworkManager.shared.request(.followers(user: user.name!), decodingTo: [DummyUser].self) { [unowned self] (result) in
            switch result {
            case .success(let users):
                self.followersLabel.text = "Followers: \(users.count)"
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        NetworkManager.shared.request(.following(user: user.name!), decodingTo: [DummyUser].self) { [unowned self] (result) in
            switch result {
            case .success(let users):
                self.followingLabel.text = "Following: \(users.count)"
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func errorOccurred(_ error: Error) {
        
    }
    
    
}
