//
//  NetworkManager.swift
//  GitHub Users
//
//  Created by Ata Doruk on 13.12.2020.
//

import UIKit

enum RequestType {
    case users(page: Int)
    case user(username: String)
    
    private var baseUrl: String { "https://api.github.com/" }
    
    private var endpoint: String {
        switch self {
        case .users(let page): return "users?since=\(page)"
        case .user(username: let username): return "users/\(username)"
        }
    }
    
    fileprivate var parameters: [String: String]? {
        switch self {
        case .users(page: let page): return ["since": "\(page)"]
        default: return nil
        }
    }
    
    var url: String { return baseUrl + endpoint }
}

enum RequestError: Error {
    case invalidUrl
    case dataNil
    case generic(Error)
}

class NetworkManager {
    private let requestsQueue = DispatchQueue(label: "com.atadoruk.github-users.requestsQueue")
    private let urlSession = URLSession.shared
    
    static let shared = NetworkManager()
    private init() {
        
    }
    
    func request<T: Decodable>(_ requestType: RequestType, decodingTo: T.Type, completion: @escaping (Result<T, RequestError>) -> Void) {
        guard let url = URL(string: requestType.url) else {
            completion(.failure(.invalidUrl))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
        requestsQueue.async(flags: .barrier) { [self] in
            urlSession.dataTask(with: request) { (data, response, error) in
                guard let data = data else {
                    completion(.failure(.dataNil))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    DispatchQueue.main.sync {
                        decoder.userInfo[CodingUserInfoKey.managedObjectContext!] = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
                    }
                    
                    let object = try decoder.decode(T.self, from: data)
                    completion(.success(object))
                } catch let error {
                    completion(.failure(.generic(error)))
                }
            }.resume()
        }
    }
}
