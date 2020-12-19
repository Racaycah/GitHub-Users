//
//  User.swift
//  GitHub Users
//
//  Created by Ata Doruk on 13.12.2020.
//

import UIKit

struct User: Codable, BaseModel {
    let name: String
    let id: Int
    let avatarUrl: String
    let followersUrl: String
    let followingUrl: String
    
    enum CodingKeys: String, CodingKey {
        case name = "login"
        case id
        case avatarUrl = "avatar_url"
        case followersUrl = "followers_url"
        case followingUrl = "following_url"
    }
}
