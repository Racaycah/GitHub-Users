//
//  AsyncImageView.swift
//  GitHub Users
//
//  Created by Ata Doruk on 23.01.2021.
//

import UIKit

class AsyncImageView: UIImageView {
    private var imageLoadTask: URLSessionDataTask!
    private var spinner = UIActivityIndicatorView(style: .medium)
    
    func loadImage(from url: URL) {
        image = nil
        
        addSpinner()
        
        if let imageTask = imageLoadTask {
            imageTask.cancel()
        }
        
        if let cachedImage = ImageCache.image(for: url) {
            image = cachedImage
            removeSpinner()
            return
        }
        
        imageLoadTask = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            guard let data = data, let fetchedImage = UIImage(data: data) else {
                print("Cancelled loading image")
                return
            }
            
            ImageCache.save(image: fetchedImage, for: url)
            CoreDataManager.shared.saveImage(fetchedImage, forUrl: url)
            
            DispatchQueue.main.async {
                self.image = fetchedImage
                self.removeSpinner()
            }
        }
        
        imageLoadTask.resume()
    }
    
    func cancelDownload() {
        if let task = imageLoadTask {
            task.cancel()
        }
    }
    
    private func addSpinner() {
        addSubview(spinner)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        spinner.startAnimating()
    }
    
    private func removeSpinner() {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }
}

