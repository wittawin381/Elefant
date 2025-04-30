//
//  MediaView.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 11/4/2568 BE.
//

import Foundation
import UIKit
import AVKit

class MediaView: UIView {
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: MediaCollectionViewLayout())
    private var appliedConfiguration: MediaViewConfiguration = .init(mediaAttachments: [])
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    private var borderLayer: CAShapeLayer?
    private var preferredMaxContentWidth: CGFloat = 0
    private lazy var collectionWidthAnchor: NSLayoutConstraint = collectionView.widthAnchor.constraint(equalToConstant: 0)
    var visibleMediaPreview: [MediaPreviewableItem] {
        collectionView.visibleCells
            .compactMap {
                if $0.contentView is VideoPreview && $0.contentView is MediaPreviewableItem {
                    return $0.contentView as? MediaPreviewableItem
                }
                return nil
            }
    }
    var currentPlayingItem: MediaPreviewableItem? 
    
    enum Section: Hashable {
        case main
    }
    
    enum Item: Hashable {
        case image(ImagePreviewConfiguration)
        case video(VideoPreviewConfiguration)
        
        var configuration: any UIContentConfiguration {
            switch self {
            case let .image(configuration):
                configuration
            case let .video(configuration):
                configuration
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        if preferredMaxContentWidth == 0 {
            return CGSize(width: UIView.noIntrinsicMetric, height: 200)
        }
        if let mediaItem = appliedConfiguration.mediaAttachments.first, appliedConfiguration.mediaAttachments.count == 1 {
            let aspect = switch mediaItem {
            case let .image(imagePreviewConfiguration):
                imagePreviewConfiguration.aspect 
            case let .video(videoPreviewConfiguration):
                videoPreviewConfiguration.aspect
            }
            
            let height = preferredMaxContentWidth / aspect
            let finalHeight = min(400, height)
            let width = finalHeight * aspect
            let size = CGSize(width: width, height: finalHeight)
            collectionWidthAnchor.constant = width
            return size
        } else {
            let size = CGSize(width: preferredMaxContentWidth, height: 200)
            collectionWidthAnchor.constant = preferredMaxContentWidth
            return size
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupLayout()
        setupCollectionView()
        
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
            self.borderLayer?.strokeColor = UIColor.systemGray6.cgColor
        }
    }
    
    override func layoutSubviews() {
        if preferredMaxContentWidth != bounds.width {
            preferredMaxContentWidth = bounds.width
            
            return invalidateIntrinsicContentSize()
        }
        
        super.layoutSubviews()
        let cornerPath = UIBezierPath(
            roundedRect: CGRect(
                x: 0,
                y: 0,
                width: intrinsicContentSize.width,
                height: intrinsicContentSize.height),
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(width: 16, height: 16))
        let mask = CAShapeLayer()
        mask.path = cornerPath.cgPath
        layer.mask = mask
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.cornerCurve = .continuous
        
        if let borderLayer {
            borderLayer.path = cornerPath.cgPath
        } else {
            let borderLayer = CAShapeLayer()
            borderLayer.path = cornerPath.cgPath
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.strokeColor = UIColor.systemGray6.cgColor
            borderLayer.lineWidth = 2
            self.borderLayer = borderLayer
            layer.addSublayer(borderLayer)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionWidthAnchor,
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        
        let imageCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Item> { cell, indexPath, item in
            cell.contentConfiguration = item.configuration
        }
        
        let videoCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Item> { cell, indexPath, item in
            cell.contentConfiguration = item.configuration
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .image(_):
                collectionView.dequeueConfiguredReusableCell(using: imageCellRegistration, for: indexPath, item: item)
            case .video(_):
                collectionView.dequeueConfiguredReusableCell(using: videoCellRegistration, for: indexPath, item: item)
            }
        }
    }
    
    func startVideoPlayback() {
        let viewToPlay = visibleMediaPreview.first
        viewToPlay?.start()
        self.currentPlayingItem = viewToPlay
    }
    
    func stopVideoPlayback() {
        self.currentPlayingItem?.stop()
        self.currentPlayingItem = nil
    }
}

extension MediaView: UIContentView {
    var configuration: any UIContentConfiguration {
        get { appliedConfiguration }
        set(newValue) {
            guard let newConfiguration = newValue as? MediaViewConfiguration else { return }
            apply(configuration: newConfiguration)
        }
    }
    
    func apply(configuration: MediaViewConfiguration) {
        appliedConfiguration = configuration
        
        invalidateIntrinsicContentSize()
    
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(configuration.mediaAttachments.map { media in
            switch media {
            case let .image(data):
                .image(ImagePreviewConfiguration(
                    previewURL: data.previewURL,
                    blurhash: data.blurhash,
                    aspect: data.aspect))
            case let .video(data):
                .video(VideoPreviewConfiguration(
                    previewURL: data.previewURL,
                    previewImageURL: data.previewImageURL,
                    url: data.url,
                    blurhash: data.blurhash,
                    aspect: data.aspect))
            }
        })
        dataSource?.apply(snapshot)
        collectionView.collectionViewLayout.invalidateLayout()

    }
}

//MARK: CollectionViewDelegate --------------------------------------------

extension MediaView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
}

//MARK: CollectionViewLayout ----------------------------------------------
class MediaCollectionViewLayout: UICollectionViewFlowLayout {
    private let maxNumberOfItems: Int = 4
    private let spacing: CGFloat = 2
    private var cachedAttributes: [UICollectionViewLayoutAttributes] = []
    
    enum LayoutType: Int {
        case full
        case half
        case oneThirdsTwoThirds
        case oneFourth
        
        init?(rawValue: Int) {
            switch rawValue {
            case 1: self = .full
            case 2: self = .half
            case 3: self = .oneThirdsTwoThirds
            case 4: self = .oneFourth
            default: self = .full
            }
        }
    }
    
    override var collectionViewContentSize: CGSize {
        collectionView?.bounds.size ?? .zero
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        cachedAttributes.removeAll()
    }
    
    override func prepare() {
        super.prepare()
        cachedAttributes.removeAll()
        guard let collectionView, collectionView.numberOfSections > 0 else { return }
        let numberOfItems = min(collectionView.numberOfItems(inSection: 0), maxNumberOfItems)
        if numberOfItems == 0 { return }
        let layoutType = LayoutType(rawValue: numberOfItems) ?? .full
        
        let itemsRect = createLayout(
            for: layoutType,
            collectionViewWidth: collectionView.bounds.width,
            maxContentHeight: collectionView.bounds.height)
        
        cachedAttributes = itemsRect.enumerated().map { index, rect in
            let layoutAtribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: index, section: 0))
            layoutAtribute.frame = rect
            return layoutAtribute
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cachedAttributes[indexPath.row]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        //No need to find a rect in collectionView since we displaying all item
        cachedAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
        
    private func createLayout(for layoutType: LayoutType, collectionViewWidth: CGFloat, maxContentHeight: CGFloat) -> [CGRect] {
        let halfSpacing = spacing / 2
        switch layoutType {
        case .full:
            let rect = CGRect(x: 0, y: 0, width: collectionViewWidth, height: maxContentHeight)
            return [rect]
        case .half:
            let firstRect = CGRect(
                x: 0,
                y: 0,
                width: (collectionViewWidth / 2) - halfSpacing,
                height: maxContentHeight)
            let secondRect = CGRect(
                x: (collectionViewWidth / 2) + halfSpacing,
                y: 0,
                width: (collectionViewWidth / 2) - halfSpacing,
                height: maxContentHeight)
            return [firstRect, secondRect]
        case .oneThirdsTwoThirds:
            let firstRect = CGRect(
                x: 0,
                y: 0,
                width: (collectionViewWidth / 2) - halfSpacing,
                height: maxContentHeight - halfSpacing)
            let secondRect = CGRect(
                x: (collectionViewWidth / 2) + halfSpacing,
                y: 0,
                width: (collectionViewWidth / 2) - halfSpacing,
                height: (maxContentHeight / 2) - halfSpacing)
            let thirdRect = CGRect(
                x: (collectionViewWidth / 2) + halfSpacing,
                y: (maxContentHeight / 2) + halfSpacing,
                width: (collectionViewWidth / 2) - halfSpacing,
                height: (maxContentHeight / 2) - halfSpacing)
            return [firstRect, secondRect, thirdRect]
        case .oneFourth:
            let firstRect = CGRect(
                x: 0,
                y: 0,
                width: (collectionViewWidth / 2) - halfSpacing,
                height: (maxContentHeight / 2) - halfSpacing)
            let secondRect = CGRect(
                x: 0,
                y: (maxContentHeight / 2) + halfSpacing,
                width: (collectionViewWidth / 2) - halfSpacing,
                height: (maxContentHeight / 2) - halfSpacing)
            let thirdRect = CGRect(
                x: (collectionViewWidth / 2) + halfSpacing,
                y: 0,
                width: (collectionViewWidth / 2) - halfSpacing,
                height: (maxContentHeight / 2) - halfSpacing)
            let fourthRect = CGRect(
                x: (collectionViewWidth / 2) + halfSpacing,
                y: (maxContentHeight / 2) + halfSpacing,
                width: (collectionViewWidth / 2) - halfSpacing,
                height: (maxContentHeight / 2) - halfSpacing)
            return [firstRect, secondRect, thirdRect, fourthRect]
        }
    }
}
