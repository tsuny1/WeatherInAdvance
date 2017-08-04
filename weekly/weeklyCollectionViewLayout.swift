//
//  weeklyCollectionViewLayout.swift
//  weekly
//
//  Created by Will Yeung on 7/25/17.
//  Copyright © 2017 Will Yeung. All rights reserved.
//

import UIKit

class weeklyCollectionViewLayout:  UICollectionViewFlowLayout {
    
    // MARK: - Collection View Flow Layout Methods
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    
}
