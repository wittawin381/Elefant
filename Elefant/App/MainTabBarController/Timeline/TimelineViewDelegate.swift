//
//  MediaCollectionViewDelegate.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 17/4/2568 BE.
//

import Foundation
import UIKit

@MainActor protocol MediaCollectionViewCellProvider {
    var hasVideo: Bool { get }
    
    var mediaViewFrame: CGRect { get }
    func startPlayingMedia()
    func stopPlayingMedia()
}

@MainActor protocol TimelineViewDelegate: AnyObject {
    func timelineWillFetchMore()
}

class TimelineCollectionViewDelegate: NSObject, UICollectionViewDelegate {
    weak var timelineViewDelegate: TimelineViewDelegate?
    
    private func currentIndexPathOfPlayingItemIn(collectionView: UICollectionView) -> IndexPath? {
        guard let currentMeidaView else { return nil }
        return collectionView.indexPath(for: currentMeidaView.item)
    }
    
    private var currentMeidaView: VisibleMediaView?
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else { return }
                    
        let collectionViewVisibleBounds = CGRect(
            x: collectionView.bounds.origin.x + collectionView.adjustedContentInset.left,
            y: collectionView.bounds.origin.y + collectionView.adjustedContentInset.top,
            width: collectionView.bounds.width - Double(collectionView.adjustedContentInset.left + collectionView.adjustedContentInset.right),
            height: collectionView.bounds.height - Double(collectionView.adjustedContentInset.top + collectionView.adjustedContentInset.bottom))
        
        let visibleVideoCells = collectionView.visibleCells.filter { cell in
            if let mediaCell = cell.contentView as? MediaCollectionViewCellProvider, mediaCell.hasVideo {
                return true
            }
            return false
        }
            .map { VisibleMediaView(item: $0) }
            .sorted { $0.displayPercentage(in: collectionViewVisibleBounds, of: collectionView) > $1.displayPercentage(in: collectionViewVisibleBounds, of: collectionView) }
        
        if visibleVideoCells.isEmpty {
            currentMeidaView = nil
        }
        
        if (currentMeidaView != nil) {
           
            if let firstItem = visibleVideoCells.first?.item {
                if (currentIndexPathOfPlayingItemIn(collectionView: collectionView) != collectionView.indexPath(for: firstItem)) {
                    currentMeidaView?.itemAsMediaCollectionViewCellProvider?.stopPlayingMedia()
                    currentMeidaView = visibleVideoCells.first
                    currentMeidaView?.itemAsMediaCollectionViewCellProvider?.startPlayingMedia()
                }
            } else {
                currentMeidaView?.itemAsMediaCollectionViewCellProvider?.stopPlayingMedia()
            }
            
            if currentMeidaView?.displayPercentage(in: collectionViewVisibleBounds, of: collectionView) ?? 0 < 0.5 {
                currentMeidaView?.itemAsMediaCollectionViewCellProvider?.stopPlayingMedia()
            } else {
                currentMeidaView?.itemAsMediaCollectionViewCellProvider?.startPlayingMedia()
            }
            
        } else {
            currentMeidaView = visibleVideoCells.first
            currentMeidaView?.itemAsMediaCollectionViewCellProvider?.startPlayingMedia()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let loadMoreView = cell.contentView as? LoadMoreView {
            loadMoreView.startAnimating()
            timelineViewDelegate?.timelineWillFetchMore()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
}

@MainActor struct VisibleMediaView {
    let item: UICollectionViewCell
    
    var itemAsMediaCollectionViewCellProvider: MediaCollectionViewCellProvider? {
        item.contentView as? MediaCollectionViewCellProvider
    }

    func intersection(with rect: CGRect, in coordinateSpace: UIView) -> CGRect? {
        guard let mediaView = item.contentView as? MediaCollectionViewCellProvider else { return nil }
        return item.convert(mediaView.mediaViewFrame, to: coordinateSpace).intersection(rect)
    }
    
    func displayPercentage(in rect: CGRect, of coordinateSpace: UIView) -> CGFloat {
        guard let mediaView = item.contentView as? MediaCollectionViewCellProvider else { return .zero }
        let intersectArea = intersection(with: rect, in: coordinateSpace)?.area ?? .zero
        let mediaViewArea = item.convert(mediaView.mediaViewFrame, to: coordinateSpace).area
        
        return intersectArea / mediaViewArea
    }
}

extension CGRect {
    var area: CGFloat {
        width * height
    }
}
