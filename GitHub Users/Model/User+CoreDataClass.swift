//
//  User+CoreDataClass.swift
//  GitHub Users
//
//  Created by Ata Doruk on 25.12.2020.
//
//

import Foundation
import CoreData


public class User: NSManagedObject {
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
