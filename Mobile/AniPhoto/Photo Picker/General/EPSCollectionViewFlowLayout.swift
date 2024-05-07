//
//  EPSCollectionViewFlowLayout.swift
//  AniPhoto
//
//  Created by PhatCH on 2023/4/20.
//

import UIKit

class EPSCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override var flipsHorizontallyInOppositeLayoutDirection: Bool { isRTL() }
}
