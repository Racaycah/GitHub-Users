//
//  UsersListViewController.swift
//  GitHub Users
//
//  Created by Ata Doruk on 13.12.2020.
//

import UIKit

class UsersListViewController: UIViewController {
    
    // MARK: - Properties
    
    var usersCollectionView: UICollectionView!
    let collectionViewFlowLayout: UICollectionViewFlowLayout =  {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 20, height: 80)
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width - 20, height: 80)
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        return layout
    }()
    
    let usersViewModel = UsersViewModel()
    
    private let segueIdentifier = "userDetailSegue"
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        usersCollectionView.collectionViewLayout = collectionViewFlowLayout
        usersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        usersCollectionView.delegate = self
        usersCollectionView.dataSource = self
        
        view.addSubview(usersCollectionView)
        
        NSLayoutConstraint.activate([
            usersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            usersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            usersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            usersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        usersCollectionView.register(UINib(nibName: UserCollectionViewCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: UserCollectionViewCell.reuseIdentifier)
        usersCollectionView.register(UINib(nibName: LoadingCollectionViewCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: LoadingCollectionViewCell.reuseIdentifier)
        
        usersViewModel.delegate = self
        
//        usersViewModel.deleteAllUsers()
        usersViewModel.getUsers()
    }
    
    // MARK: - Segue Handling
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == segueIdentifier, let profileVC = segue.destination as? ProfileViewController, let user = sender as? User else { return }
        profileVC.profileViewModel = ProfileViewModel(user: user)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension UsersListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: UIScreen.main.bounds.width - 20, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard usersViewModel.users.count != 0 else { return }
        
        if indexPath.item == usersViewModel.users.count {
            usersViewModel.getUsers()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = usersViewModel.users[indexPath.item]
        performSegue(withIdentifier: segueIdentifier, sender: user)
    }
}

// MARK: - UICollectionViewDataSource

extension UsersListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        usersViewModel.users.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        indexPath.item == usersViewModel.users.count ? usersViewModel.getLoadingCell(from: collectionView, indexPath: indexPath) : usersViewModel.getCell(from: collectionView, indexPath: indexPath)
    }
    
}

// MARK: - UsersViewModelDelegate

extension UsersListViewController: UsersViewModelDelegate {
    func reloadData() {
        DispatchQueue.main.async {
            self.usersCollectionView.reloadData()
        }
    }
}
