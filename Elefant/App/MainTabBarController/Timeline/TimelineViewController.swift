//
//  TimelineViewController.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 4/4/2568 BE.
//

import Foundation
import UIKit
import ElefantEntity

class TimelineViewController: UIViewController {
    private let refreshControl = UIRefreshControl()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private let timelineCollectionViewDelegate = TimelineCollectionViewDelegate()
    private var currentTimelineMode: TimelineRequestType = .home {
        didSet {
            fetchTimeline(mode: currentTimelineMode)
            title = currentTimelineMode.title
        }
    }
    var dataController: TimelineInternalDataController
    
    init(dataController: TimelineInternalDataController) {
        self.dataController = dataController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupView()
        setupNavigationBarItems()
        view.backgroundColor = .systemBackground
        fetchTimeline(mode: currentTimelineMode)
        
        title = currentTimelineMode.title
    }
    
    private func fetchTimeline(mode: TimelineRequestType) {
        Task {
            do {
                try await dataController.refreshTimeline(limit: 20, request: mode)
            } catch {
                
            }
        }
    }
    
    private func setupLayout() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupView() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.itemSeparatorHandler = { [weak self] indexPath, configuration in
            guard let self else { return configuration }
            var newConfiguration = configuration
            
            if let snapshot = dataController.dataSource?.snapshot() {
                let section = snapshot.sectionIdentifiers[indexPath.section]
                let items = snapshot.itemIdentifiers(inSection: section)
                let item = items[indexPath.row]
                
                if case .statusMediaView(_) = item {
                    newConfiguration.topSeparatorVisibility = .hidden
                    newConfiguration.bottomSeparatorVisibility = .hidden
                }
                
                if case .statusTextContent(_) = item {
                    newConfiguration.topSeparatorVisibility = .hidden
                    newConfiguration.bottomSeparatorVisibility = .hidden
                }
                
                if case .statusHeader(_) = item {
                    newConfiguration.bottomSeparatorVisibility = .hidden
                }
            }
            
            
            if indexPath.section == 0, indexPath.row == 0 {
                newConfiguration.topSeparatorVisibility = .hidden
            }
            if indexPath.section == collectionView.numberOfSections - 2, indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) - 1 {
                newConfiguration.bottomSeparatorVisibility = .hidden
            }
            if let section = dataController.dataSource?.snapshot().sectionIdentifiers[indexPath.section] {
                if case .loadMore = section {
                    newConfiguration.topSeparatorVisibility = .hidden
                    newConfiguration.bottomSeparatorVisibility = .hidden
                }
            }
            return newConfiguration
        }
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
        dataController.setup(collectionView: collectionView)
        
        timelineCollectionViewDelegate.timelineViewDelegate = self
        collectionView.delegate = timelineCollectionViewDelegate
        
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(timelineDidLoadTop), for: .valueChanged)
    }
    
    private func setupNavigationBarItems() {
        let timelineTypeButton = UIBarButtonItemGroup(
            barButtonItems: [
                UIBarButtonItem(title: "Menu", style: .plain, target: self, action: nil)],
            representativeItem: nil)
        timelineTypeButton.alwaysAvailable = true
        
        navigationItem.titleMenuProvider = { _ in
            let followingTimeline = UICommand(title: "following", image: UIImage(systemName: "house"), action: #selector(self.timelineModeFollowingDidSelect))
            let globalTimeline = UICommand(title: "global", image: UIImage(systemName: "globe.central.south.asia"), action: #selector(self.timelineModeGlobalDidSelect))
            let localTimeline = UICommand(title: "local", image: UIImage(systemName: "location.circle"), action: #selector(self.timelineModeLocalDidSelect))
            
            return UIMenu(children: [
                followingTimeline,
                globalTimeline,
                localTimeline
            ])
        }
    }
    
    @objc private func timelineModeFollowingDidSelect() {
        currentTimelineMode = .home
    }
    
    @objc private func timelineModeGlobalDidSelect() {
        currentTimelineMode = .public(local: false, remote: true, onlyMedia: false)
    }
    
    @objc private func timelineModeLocalDidSelect() {
        currentTimelineMode = .public(local: true, remote: false, onlyMedia: false)
    }
    
    @objc private func timelineDidLoadTop() {
        Task {
            do {
                let before = collectionView.contentSize.height;
                let firstCell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0))
                
                print("before: \(before) \(collectionView.contentOffset.y)")
                try await dataController.fetchBeforeFirst(limit: 20, request: currentTimelineMode)
                print("after: \(collectionView.contentSize.height)")
                collectionView.contentOffset.y = (firstCell?.frame.minY ?? 0) - collectionView.adjustedContentInset.top
                refreshControl.endRefreshing()
                CATransaction.commit()

            } catch {
                
            }
        }
    }
}

extension TimelineViewController: TimelineViewDelegate {
    func timelineWillFetchMore() {
        Task {
            do {
                try await dataController.fetchMore(limit: 20, request: currentTimelineMode)
            } catch {
                
            }
        }
    }
}
