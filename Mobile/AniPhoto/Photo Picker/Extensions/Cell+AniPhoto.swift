//
//  Cell+AniPhoto.swift
//  AniPhoto
//
//  Created by PhatCH on 2020/8/13.
//

import UIKit

extension AniPhotoWrapper where Base: UICollectionViewCell {
    static var identifier: String {
        NSStringFromClass(Base.self)
    }
    
    static func register(_ collectionView: UICollectionView) {
        collectionView.register(Base.self, forCellWithReuseIdentifier: identifier)
    }
}

extension AniPhotoWrapper where Base: UITableViewCell {
    static var identifier: String {
        NSStringFromClass(Base.self)
    }
    
    static func register(_ tableView: UITableView) {
        tableView.register(Base.self, forCellReuseIdentifier: identifier)
    }
}
