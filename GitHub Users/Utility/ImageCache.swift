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
    private init() {}
    
    func fetch(from url: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.object(forKey: NSString(string: url)) {
            DispatchQueue.main.async {
                completion(cachedImage)
            }
        } else {
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: URL(string: url)!) {
                    if let image = UIImage(data: data) {
                        self?.cache.setObject(image, forKey: NSString(string: url))
                        DispatchQueue.main.async {
                            completion(image)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
    }
}
