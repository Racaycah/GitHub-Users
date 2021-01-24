//
//  GitHub_UsersTests.swift
//  GitHub UsersTests
//
//  Created by Ata Doruk on 13.12.2020.
//

import XCTest
@testable import GitHub_Users

class GitHub_UsersTests: XCTestCase {
    
    let networkManager = NetworkManager.shared
    
    func testUserListFetch() {
        let expectation = self.expectation(description: "User Fetching")
        var users = [UserModel]()
        
        networkManager.request(.users(page: 0), decodingTo: [UserModel].self) { (result) in
            switch result {
            case .success(let fetchedUsers):
                users = fetchedUsers
                // Every batch returns 30 users
                if fetchedUsers.count == 30 {
                    expectation.fulfill()
                }
            case .failure(_):
                break
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertEqual(30, users.count)
    }
    
    func testUserDetailsFetch() {
        let username = "mojombo"
        var userDetails: UserModel?
        
        let expectation = self.expectation(description: "mojombo User Details")
        
        networkManager.request(.user(username: username), decodingTo: UserModel.self) { (result) in
            switch result {
            case .success(let details):
                userDetails = details
                expectation.fulfill()
            case .failure:
                break
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertNotNil(userDetails)
    }
    
    

}
