//
//  ServerPickerViewController.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 3/4/2568 BE.
//

import Foundation
import UIKit
import ElefantAPI
import ElefantEntity

@MainActor protocol ServerPickerViewControllerDelegate: AnyObject {
    func serverPickerViewController(_ viewController: ServerPickerViewController, didSelectServer server: Server)
}

class ServerPickerViewController: UIViewController {
    private let networkDataSource: ServerPickerNetworkDataSource = DefaultServerPickerNetworkDataSource(
        client: ElefantClient(
            session: URLSession.shared,
            server: ElefantClient.Server(domain: "api.joinmastodon.org")))
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var dataSource = ServerPickerDataSource()
    
    weak var delegate: ServerPickerViewControllerDelegate?
    
    override func viewDidLoad() {
        setupLayout()
        setupView()
        
        getServerList()
    }
    
    private func getServerList() {
        Task {
            do {
                let items = try await networkDataSource.getServerPickerItems()
                dataSource.update(items: items)
                collectionView.refreshControl?.endRefreshing()
            } catch {}
        }
    }
}

extension ServerPickerViewController {
    private func setupLayout() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupView() {
        navigationItem.title = "Servers"
        view.backgroundColor = .systemBackground
        
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = dataSource
        
        setupCollectionView()
        
        let refreshControl = UIRefreshControl()
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        dataSource.setup(with: collectionView)
        
        let collectionViewLayout = UICollectionViewCompositionalLayout.list(using: .init(appearance: .insetGrouped))
        collectionView.collectionViewLayout = collectionViewLayout
    }
    
    @objc private func handleRefreshControl() {
        getServerList()
    }
}

extension ServerPickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let server = dataSource.items[indexPath.section]
        
        delegate?.serverPickerViewController(self, didSelectServer: server)
    }
}
