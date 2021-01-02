//
//  ImageCache.swift
//  GitHub Users
//
//  Created by Ata Doruk on 19.12.2020.
//

import UIKit

class ImageCache {
    static let shared = ImageCache()
    private var cache = NSCache<NSString, UIImage>()
    private var runningRequests = [String: URLSessionDataTask]()
    private init() {}
    
    func fetch(from url: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.object(forKey: NSString(string: url)) {
            DispatchQueue.main.async {
                completion(cachedImage)
            }
        } else {
            guard let imageURL = URL(string: url) else { completion(nil); return }
            
            let imageDownloadTask = URLSession.shared.dataTask(with: imageURL) { [weak self] data, _, _ in
                
                defer { self?.runningRequests.removeValue(forKey: url) }
                
                if let data = data, let image = UIImage(data: data) {
                    self?.cache.setObject(image, forKey: NSString(string: url))
                    DispatchQueue.main.async {
                        completion(image)
                    }
                    return
                }
                
                completion(nil)
            }
            
            imageDownloadTask.resume()
            
            runningRequests[url] = imageDownloadTask
            
//            DispatchQueue.global().async { [weak self] in
//                if let data = try? Data(contentsOf: URL(string: url)!) {
//                    if let image = UIImage(data: data) {
//                        self?.cache.setObject(image, forKey: NSString(string: url))
//                        DispatchQueue.main.async {
//                            completion(image)
//                        }
//                    } else {
//                        DispatchQueue.main.async {
//                            completion(nil)
//                        }
//                    }
//                } else {
//                    DispatchQueue.main.async {
//                        completion(nil)
//                    }
//                }
//            }
        }
    }
    
    func cancelIfRunning(forURL url: String) {
        runningRequests[url]?.cancel()
        runningRequests.removeValue(forKey: url)
    }
}
