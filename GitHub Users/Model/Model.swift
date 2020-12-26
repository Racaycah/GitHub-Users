//
//  Model.swift
//  GitHub Users
//
//  Created by Ata Doruk on 19.12.2020.
//

import Foundation

protocol BaseModel {
    
}

protocol DataModel: class {
    associatedtype model = BaseModel
}

struct DummyUser: Decodable {
    let login: String
}
