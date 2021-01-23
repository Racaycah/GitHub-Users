//
//  User+CoreDataProperties.swift
//  GitHub Users
//
//  Created by Ata Doruk on 25.12.2020.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<User> {
        let request = NSFetchRequest<User>(entityName: "User")
        request.sortDescriptors = [.init(key: "id", ascending: true)]
        
        return request
    }

    @NSManaged public var avatarUrl: String?
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var fullName: String?
    @NSManaged public var company: String?
    @NSManaged public var blog: String?
    @NSManaged public var image: Data?
    @NSManaged public var note: String?
}

extension User : Identifiable {

}
