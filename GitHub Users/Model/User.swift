//
//  User.swift
//  GitHub Users
//
//  Created by Ata Doruk on 25.12.2020.
//

import Foundation
import CoreData

//class User: NSManagedObject, Codable, BaseModel {
//
//    enum CodingKeys: String, CodingKey {
//        case name = "login"
//        case id
//        case avatarUrl = "avatar_url"
//        case followersUrl = "followers_url"
//        case followingUrl = "following_url"
//    }
//
//    required init(from decoder: Decoder) throws {
//        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext!] as? NSManagedObjectContext else {
//            throw NSError()
//        }
//
//        self.init(context: context)
//    }
//
//    func encode(to encoder: Encoder) throws {
//
//    }
//}

/* https://www.donnywals.com/using-codable-with-core-data-and-nsmanagedobject/ */
extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}
