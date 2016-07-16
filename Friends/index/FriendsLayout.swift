//
//  FriendsLayout.swift
//  Friends
//
//  Created by D_ttang on 16/5/5.
//  Copyright © 2016年 D_ttang. All rights reserved.
//

import UIKit

class FriendsLayout: UICollectionViewFlowLayout {
    let kDistanceToProjectionPlane: CGFloat = 500.0
    
    var maxCoverDegree: CGFloat = 30.0
    var coverDensity: CGFloat = 0.25
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let indexPaths = indexPathsOfItemsInRect(rect)
        
        var resultingAttributes = [UICollectionViewLayoutAttributes]()
        
        for indexPath in indexPaths {
            let attributes = layoutAttributesForItemAtIndexPath(indexPath)!
            resultingAttributes.append(attributes)
        }
        return resultingAttributes
    }
    
    
    var ActiveDistance:CGFloat = 350
    var ScaleFactor:CGFloat = 0.1
    
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        
        attributes.size = itemSize
//        attributes.size = CGSizeMake(180, 350)
        attributes.center = CGPoint(x: collectionView!.bounds.size.width * CGFloat(indexPath.row) + collectionView!.bounds.size.width / 2, y: collectionView!.bounds.size.height / 2 - 32 - 25)
        interpolateAttributes(attributes, forOffset: collectionView!.contentOffset.x)
        var visibleRect: CGRect = CGRectZero
        visibleRect.origin = collectionView!.contentOffset
        visibleRect.size = collectionView!.bounds.size
        let distance = CGRectGetMidX(visibleRect) - attributes.center.x
        let normalizedDistance = distance / ActiveDistance
        let zoom = 1 + ScaleFactor*(1 - abs(normalizedDistance));
        attributes.transform3D = CATransform3DMakeScale(1.0, zoom, 1.0);
        return attributes
    }
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: collectionView!.bounds.width * CGFloat(collectionView!.numberOfItemsInSection(0)), height: collectionView!.bounds.height - 64 - 50 )
    }
    
}


// MARK: - private method
private extension FriendsLayout {
    func indexPathsOfItemsInRect(rect: CGRect) -> [NSIndexPath] {
        if collectionView!.numberOfItemsInSection(0) == 0 {
            return [NSIndexPath]()
        }
        var minRow: Int = max(Int(rect.origin.x / collectionView!.bounds.width), 0)
        var maxRow: Int = Int(CGRectGetMaxX(rect) / collectionView!.bounds.width)
        
        let candidateMinRow = max(minRow - 1, 0)
        if maxXForRow(candidateMinRow) >= rect.origin.x {
            minRow = candidateMinRow
        }
        
        let candidateMaxRow = min(maxRow + 1, collectionView!.numberOfItemsInSection(0) - 1)
        if minXForRow(candidateMaxRow) <= CGRectGetMaxX(rect) {
            maxRow = candidateMaxRow
        }
        
        var resultingInexPaths = [NSIndexPath]()
        
        for i in Int(minRow) ..< Int(maxRow) + 1 {
            resultingInexPaths.append(NSIndexPath(forRow: i, inSection: 0))
        }
        
        return resultingInexPaths
    }
    
    func minXForRow(row: Int) -> CGFloat {
        return itemCenterForRow(row - 1).x + (1 / 2 - coverDensity) * itemSize.width
    }
    
    func maxXForRow(row: Int) -> CGFloat {
        return itemCenterForRow(row + 1).x - (1 / 2 - coverDensity) * itemSize.width
    }
    
    func minXCenterForRow(row: Int) -> CGFloat {
        let halfWidth = itemSize.width / 2
        let maxRads = maxCoverDegree * CGFloat(M_PI) / 180
        let center = itemCenterForRow(row - 1).x
        let prevItemRightEdge = center + halfWidth
        let projectedLeftEdgeLocal = halfWidth * cos(maxRads) * kDistanceToProjectionPlane / (kDistanceToProjectionPlane + halfWidth * sin(maxRads))
        return prevItemRightEdge - coverDensity * itemSize.width + projectedLeftEdgeLocal
    }
    
    func maxXCenterForRow(row: Int) -> CGFloat {
        let halfWidth = itemSize.width / 2
        let maxRads = maxCoverDegree * CGFloat(M_PI) / 180
        let center = itemCenterForRow(row + 1).x
        let nextItemLeftEdge = center - halfWidth
        let projectedRightEdgeLocal = fabs(halfWidth * cos(maxRads) * kDistanceToProjectionPlane / (-halfWidth * sin(maxRads) - kDistanceToProjectionPlane))
        return nextItemLeftEdge + coverDensity * itemSize.width - projectedRightEdgeLocal
    }
    
    func itemCenterForRow(row: Int) -> CGPoint {
        let collectionViewSize = collectionView!.bounds.size
        return CGPoint(x: CGFloat(row) * collectionViewSize.width + collectionViewSize.width / 2, y: collectionViewSize.height / 2)
    }
    
    func interpolateAttributes(attributes: UICollectionViewLayoutAttributes, forOffset offset: CGFloat) {
        let attributesPath = attributes.indexPath
        
//        print(attributesPath.row)
        
        let minInterval = CGFloat(attributesPath.row - 1) * collectionView!.bounds.width
        let maxInterval = CGFloat(attributesPath.row + 1) * collectionView!.bounds.width
//        print("\(minInterval) \(maxInterval)")
        let minX = minXCenterForRow(attributesPath.row)
        let maxX = maxXCenterForRow(attributesPath.row)
//        print("\(minX) \(maxX)")
//        print(offset)
//        let interpolatedX = min(
//            minX,
//            maxX)
        let interpolatedX = min(
            max(minX + (((maxX - minX) / (maxInterval - minInterval)) * (offset - minInterval)), minX),
            maxX)
        attributes.center = CGPoint(x: interpolatedX, y: attributes.center.y)
      
//        attributes.zIndex = NSIntegerMax - attributesPath.row
        
//        var visibleRect: CGRect = CGRectZero
//        visibleRect.origin = collectionView!.contentOffset
//        visibleRect.size = collectionView!.bounds.size
//        let distance = CGRectGetMidX(visibleRect) - attributes.center.x
//        let normalizedDistance = distance / ActiveDistance
//        let zoom = 1 + ScaleFactor*(1 - abs(normalizedDistance));
//        attributes.transform3D = CATransform3DMakeScale(1.0, zoom, 1.0);
    }
}
