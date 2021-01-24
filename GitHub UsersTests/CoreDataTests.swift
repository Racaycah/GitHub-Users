//
//  CoreDataTests.swift
//  GitHub UsersTests
//
//  Created by Ata Doruk on 24.01.2021.
//

import XCTest

@testable import GitHub_Users

class CoreDataTests: XCTestCase {
    
    static let user = UserModel(name: "atadoruk", avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4", id: 1999, fullName: nil, company: nil, blog: nil, image: nil, note: nil)
    
    func testSavingUser() {
        let previousCount = CoreDataManager.shared.fetchResultsController.fetchedObjects?.count ?? 0
        CoreDataManager.shared.save(users: [CoreDataTests.user])
        
        let countAfterSaving = CoreDataManager.shared.fetchResultsController.fetchedObjects?.count ?? 0
        
        XCTAssertEqual(previousCount + 1, countAfterSaving)
    }
    
    override class func tearDown() {
        super.tearDown()
        CoreDataManager.shared.delete(CoreDataTests.user)
    }
    
    func testUpdateUser() {
        let note = "Core Data Testing"
        
        if CoreDataManager.shared.getSavedUsers().count == 0 {
            CoreDataManager.shared.save(users: [CoreDataTests.user])
        }
        
        CoreDataManager.shared.updateUser(atIndex: IndexPath(item: 0, section: 0), withNote: note)
        let user = CoreDataManager.shared.userAt(index: IndexPath(item: 0, section: 0))
        
        let noteSaved = user.note == note

        XCTAssertTrue(noteSaved)
    }
}
