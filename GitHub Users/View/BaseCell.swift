//
//  BaseCell.swift
//  GitHub Users
//
//  Created by Ata Doruk on 19.12.2020.
//

import UIKit

protocol BaseCell: class {
    associatedtype Model = DataModel
    static var reuseIdentifier: String { get }
    func configureCell(with model: Model, invertImage: Bool)
}
extension BaseCell {
    static var reuseIdentifier: String { String(describing: self) }
}
