//
//  CoreDataTests.swift
//  GitHub UsersTests
//
//  Created by Ata Doruk on 24.01.2021.
//

import XCTest

@testable import GitHub_Users

class CoreDataTests: XCTestCase {
    
    let user = UserModel(name: "atadoruk", avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4", id: 1999, fullName: nil, company: nil, blog: nil, image: nil, note: nil)
    
    func testSavingUser() {
        
        CoreDataManager.shared.save(users: [user])
        
        let users = CoreDataManager.shared.fetchResultsController.fetchedObjects
        
        XCTAssertEqual(1, users?.count)
    }
    
    func testUpdateUser() {
        let user = CoreDataManager.shared.userAt(index: IndexPath(item: 0, section: 0))
        
        let note = "Core Data Testing"
        CoreDataManager.shared.updateUser(atIndex: IndexPath(item: 0, section: 0), withNote: note)
        
        let noteSaved = user.note == note
            //CoreDataManager.shared.fetchResultsController.fetchedObjects?.allSatisfy { $0.note == note }
        XCTAssertTrue(noteSaved)
    }
}
