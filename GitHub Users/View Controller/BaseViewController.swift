//
//  BaseViewController.swift
//  GitHub Users
//
//  Created by Ata Doruk on 13.12.2020.
//

import UIKit
import Network

class BaseViewController: UIViewController {
    
    private let networkQueue = DispatchQueue(label: "github-users.network.queue")
    private let networkMonitor = NWPathMonitor()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        networkMonitor.pathUpdateHandler = networkStatusChanged(_:)
        networkMonitor.start(queue: networkQueue)
    }
    
    // MARK: - Network Status Observing
    
    func networkStatusChanged(_ path: NWPath) {
        if path.status != .satisfied {
            DispatchQueue.main.async {
                self.noNetworkAvailable()
            }
        } else {
            
        }
    }
    
    func noNetworkAvailable() {
        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemGroupedBackground
        let label = UILabel()
        label.textAlignment = .center
        label.text = "No network available."
        [label, containerView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        containerView.addSubview(label)
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50),
            containerView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        UIView.animate(withDuration: 0.5) {
            containerView.transform = CGAffineTransform(translationX: 0, y: -100)
        } completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5) {
                containerView.transform = .identity
            }
        }
    }
}

