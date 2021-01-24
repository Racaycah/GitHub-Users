//
//  ProfileViewController.swift
//  GitHub Users
//
//  Created by Ata Doruk on 26.12.2020.
//

import UIKit

class ProfileViewController: BaseViewController {
    
    @IBOutlet weak var userAvatarImageView: AsyncImageView!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var infoContainerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var blogLabel: UILabel!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    weak var userDelegate: UsersViewModelDelegate?
    
    var profileViewModel: ProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoContainerView.layer.cornerRadius = 5
        infoContainerView.layer.borderWidth = 2
        infoContainerView.layer.borderColor = UIColor.secondaryLabel.cgColor
        
        noteTextView.layer.cornerRadius = 5
        noteTextView.layer.borderWidth = 2
        noteTextView.layer.borderColor = UIColor.secondaryLabel.cgColor
        
        saveButton.layer.cornerRadius = 5
        saveButton.layer.borderWidth = 2
        saveButton.layer.borderColor = UIColor.systemBlue.cgColor
        
        title = profileViewModel.user.name
        
        noteTextView.delegate = self
        noteTextView.text = profileViewModel.user.note
        
        profileViewModel.delegate = self
        profileViewModel.getUserDetails()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        profileViewModel.saveNote(noteTextView.text)
    }
    
    override func networkBecameAvailable() {
        profileViewModel.getUserDetails()
    }
}

extension ProfileViewController: ProfileViewModelDelegate {
    func userDetailsFetched(_ user: UserModel) {
        if let avatarUrl = URL(string: user.avatarUrl) {
            userAvatarImageView.loadImage(from: avatarUrl, invert: false)
        }
        
        NetworkManager.shared.request(.followers(user: user.name), decodingTo: [DummyUser].self) { [unowned self] (result) in
            switch result {
            case .success(let users):
                self.followersLabel.text = "Followers: \(users.count)"
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        NetworkManager.shared.request(.following(user: user.name), decodingTo: [DummyUser].self) { [unowned self] (result) in
            switch result {
            case .success(let users):
                self.followingLabel.text = "Following: \(users.count)"
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        nameLabel.text = "Name: \(user.fullName!)"
        let companies = user.company?.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "@", with: "").components(separatedBy: " ").first?.capitalized
        companyLabel.text = "Company: \(companies ?? "")"
        blogLabel.text = "Blog: \(user.blog ?? "")"
    }
    
    func errorOccurred(_ error: Error) {
        
    }
    
    
}

// MARK: - UITextViewDelegate

extension ProfileViewController: UITextViewDelegate {
    
}
