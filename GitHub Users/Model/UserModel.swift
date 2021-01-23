//
//  UserModel.swift
//  GitHub Users
//
//  Created by Ata Doruk on 23.01.2021.
//

import Foundation

struct UserModel: Decodable, Equatable, BaseModel {
    let name: String
    let avatarUrl: String
    let id: Int64
    let fullName: String?
    let company: String?
    let blog: String?
    var image: Data?
    var note: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "login"
        case avatarUrl = "avatar_url"
        case id
        case fullName = "name"
        case company
        case blog
        case image
        case note
    }
    
    init(managedObject: User) {
        name = managedObject.name!
        avatarUrl = managedObject.avatarUrl!
        id = managedObject.id
        fullName = managedObject.fullName
        company = managedObject.company
        blog = managedObject.blog
        image = managedObject.image
        note = managedObject.note
    }
    
    var dictionary: [String: Any] {
        var dict = [String: Any]()
        
        dict["id"] = id
        dict["name"] = name
        dict["avatarUrl"] = avatarUrl
        
        if let company = company { dict["company"] = company }
        if let blog = blog { dict["blog"] = blog }
        if let image = image { dict["image"] = image }
        if let note = note { dict["note"] = note }
        
        return dict
    }
}
