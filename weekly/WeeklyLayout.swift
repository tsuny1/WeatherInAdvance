//
//  weeklyLayour.swift
//  weekly
//
//  Created by Will Yeung on 8/6/17.
//  Copyright © 2017 Will Yeung. All rights reserved.
//

import UIKit
class weeklyLayout: UICollectionViewLayout {
    var delegate: WeeklyLayoutDelegate!
    // 2
    var numberOfColumns = 2
    
    // 3
    var numberOfRows = 0
    private var cache = [UICollectionViewLayoutAttributes]()
    
    // 4
    private var contentHeight: CGFloat  = 100
    private var contentWidth: CGFloat {
        let insets = collectionView!.bounds.width
        return insets
    }
    
    
    
    override func prepare() {
        
        if cache.isEmpty {
            let columnWidth = contentWidth / CGFloat(numberOfColumns)  - 1
            var xOffset = [CGFloat]()
            for column in 0 ..< numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth )
            }
            var column = 0
            var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
            
            
            for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
                
                column = (item >= delegate.numberOfRows()) ? 1 : 0
                
                let indexPath = IndexPath(item: item, section: 0)
                
                var height : CGFloat = 0.0
                if column == 0 {
                    
                    height = collectionView!.bounds.height / CGFloat(delegate.numberOfRows())
                }
                else {
                    height = collectionView!.bounds.height / CGFloat(delegate.numberOfRows() * 4)
                }
                let frame : CGRect
                if(column == 0) {
                    frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth / 2, height: height)
                }
                else {
                    frame = CGRect(x: xOffset[column] / 2, y: yOffset[column], width: columnWidth * 1.5, height: height)
                }
                let insetFrame = frame.insetBy(dx: 0.0, dy: 0.0)
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = insetFrame
                cache.append(attributes)
                
                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height
                
            }
            
            
            
            
        }
    }
    
    
    override var collectionViewContentSize: CGSize {
        let collection = collectionView!
        let width = collection.bounds.size.width
        let height = collection.bounds.size.width
        return CGSize(width: width, height: height)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache.first { attributes -> Bool in
            return attributes.indexPath == indexPath
        }
    }
}
