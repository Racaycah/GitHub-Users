//
//  User+CoreDataClass.swift
//  GitHub Users
//
//  Created by Ata Doruk on 25.12.2020.
//
//

import Foundation
import CoreData


public class User: NSManagedObject, BaseModel, Decodable {
    
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
    
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext!] as? NSManagedObjectContext else {
            throw NSError()
        }
        
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int64.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.avatarUrl = try container.decode(String.self, forKey: .avatarUrl)
        self.fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
        self.company = try container.decodeIfPresent(String.self, forKey: .company)
        self.blog = try container.decodeIfPresent(String.self, forKey: .blog)
        self.image = try container.decodeIfPresent(Data.self, forKey: .image)
        self.note = try container.decodeIfPresent(String.self, forKey: .note)
    }
}
