//
//  JSONDecoder+ManagedObjectContext.swift
//  GitHub Users
//
//  Created by Ata Doruk on 25.12.2020.
//

import Foundation
import CoreData

/* https://www.donnywals.com/using-codable-with-core-data-and-nsmanagedobject/ */
extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}
