//
//  UsersListViewController.swift
//  GitHub Users
//
//  Created by Ata Doruk on 13.12.2020.
//

import UIKit
import Network

class UsersListViewController: BaseViewController {
    
    // MARK: - Properties
    
    var usersCollectionView: UICollectionView!
    let collectionViewFlowLayout: UICollectionViewFlowLayout =  {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 20, height: 80)
        layout.estimatedItemSize = .zero
            //CGSize(width: UIScreen.main.bounds.width - 20, height: 80)
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        return layout
    }()
    weak var noNetworkViewBottomConstraint: NSLayoutConstraint?
    
    let searchController = UISearchController(searchResultsController: nil)
    let usersViewModel = UsersViewModel()
    
    private let segueIdentifier = "userDetailSegue"
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UICollectionView and Layout
        
        usersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        usersCollectionView.collectionViewLayout = collectionViewFlowLayout
        usersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        usersCollectionView.delegate = self
        usersCollectionView.dataSource = self
        usersCollectionView.backgroundColor = .systemBackground
        
        view.addSubview(usersCollectionView)
        
        NSLayoutConstraint.activate([
            usersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            usersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            usersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            usersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        usersCollectionView.register(UINib(nibName: UserCollectionViewCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: UserCollectionViewCell.reuseIdentifier)
        usersCollectionView.register(UINib(nibName: LoadingCollectionViewCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: LoadingCollectionViewCell.reuseIdentifier)
        
        // Place a delete button to remove users when needed
        
        let deleteButton = UIBarButtonItem(title: "Delete Saved Users", style: .done, target: self, action: #selector(deleteAllUsers))
        navigationItem.setRightBarButton(deleteButton, animated: false)
        
        usersViewModel.delegate = self
//        usersViewModel.getUsers()
        usersViewModel.loadSavedUsers()
//        usersViewModel.deleteAllUsers()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for username or note..."
        navigationItem.searchController = searchController
        
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    @objc
    func deleteAllUsers() {
        usersViewModel.deleteAllUsers()
    }
    
    override func networkBecameAvailable() {
        usersViewModel.getUsers()
    }
    
    // MARK: - Segue Handling
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == segueIdentifier, let profileVC = segue.destination as? ProfileViewController, let data = sender as? [Any], let user = data[0] as? UserModel, let index = data[1] as? IndexPath else { return }
        profileVC.profileViewModel = ProfileViewModel(user: user, index: index)
        profileVC.profileViewModel.editDelegate = self
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension UsersListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: UIScreen.main.bounds.width - 20, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard !searchController.isActive else { return }
        guard usersViewModel.users.count != 0 else { return }
        
        if indexPath.item == usersViewModel.users.count && indexPath.item != 0 {
            usersViewModel.getUsers()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = searchController.isActive ? usersViewModel.filteredUsers[indexPath.item] : usersViewModel.users[indexPath.item]
        performSegue(withIdentifier: segueIdentifier, sender: [user, indexPath])
    }
}

// MARK: - UICollectionViewDataSource

extension UsersListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        searchController.isActive ? usersViewModel.filteredUsers.count : usersViewModel.users.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        searchController.isActive ? usersViewModel.getCell(from: collectionView, indexPath: indexPath) : indexPath.item == usersViewModel.users.count ? usersViewModel.getLoadingCell(from: collectionView, indexPath: indexPath) : usersViewModel.getCell(from: collectionView, indexPath: indexPath)
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

// MARK: - UISearchResultsUpdating

extension UsersListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        usersViewModel.searchText = text
        usersCollectionView.reloadData()
    }
}

// MARK: - EditUserDelegate

extension UsersListViewController: EditUserDelegate {
    func noteSaved(forUser user: UserModel, inIndex index: IndexPath) {
        guard let filteredIndex = usersViewModel.filteredUsers.firstIndex(where: { $0.id == user.id }),
              let normalIndex = usersViewModel.users.firstIndex(where: { $0.id == user.id }) else { return }
        
        usersViewModel.filteredUsers[filteredIndex] = user
        usersViewModel.users[normalIndex] = user
        
        let indexToReload = searchController.isActive ? filteredIndex : normalIndex
        
        usersCollectionView.reloadItems(at: [IndexPath(item: indexToReload, section: 0)])
    }
}
