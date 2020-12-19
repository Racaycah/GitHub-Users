//
//  BaseCellViewModel.swift
//  GitHub Users
//
//  Created by Ata Doruk on 19.12.2020.
//

import UIKit

protocol BaseCellViewModel: class {
    associatedtype Model = DataModel
    associatedtype Cell = BaseCell
    
    func getCell(from collectionView: UICollectionView, indexPath: IndexPath) -> Cell
    func getLoadingCell(from collectionView: UICollectionView, indexPath: IndexPath) -> LoadingCollectionViewCell
}

extension BaseCellViewModel {
    func getLoadingCell(from collectionView: UICollectionView, indexPath: IndexPath) -> LoadingCollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: LoadingCollectionViewCell.reuseIdentifier, for: indexPath) as! LoadingCollectionViewCell
    }
}
