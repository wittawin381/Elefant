//
//  ServerPickerDataSource.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 3/4/2568 BE.
//

import Foundation
import UIKit
import ElefantAPI
import ElefantEntity

enum ServerPicker {
    struct Section: Hashable, Identifiable {
        let id: String
        let items: [Item]
    }
    
    struct Item: Hashable, Identifiable {
        let id: String
        let title: String
        let totalUsers: Int
        let lastWeekUsers: Int
        let description: String
        let coverImageURL: String
    }
}

protocol ServerPickerViewControllerDataSource: UISearchResultsUpdating {
    var items: [Server] { get }
    
    func setup(with collectionView: UICollectionView)
    func update(items: [Server])
}

class ServerPickerDataSource: NSObject, ServerPickerViewControllerDataSource {
    private var dataSource: UICollectionViewDiffableDataSource<ServerPicker.Section, ServerPicker.Item>?
    var items: [Server] = []
        
    func setup(with collectionView: UICollectionView) {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, ServerPicker.Item> { cell, indexPath, item in
            cell.contentConfiguration = ServerPickerViewContentConfiguration(
                serverName: item.title,
                description: item.description,
                coverImageURL: item.coverImageURL,
                totalUsers: item.totalUsers,
                lastWeekUser: item.lastWeekUsers)
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
    
    func update(items: [Server]) {
        self.items = items
        apply(items: items)
    }
    
    private func apply(items: [Server]) {
        var snapshot = NSDiffableDataSourceSnapshot<ServerPicker.Section, ServerPicker.Item>()
        items.forEach {
            let section = ServerPicker.Section(
                id: $0.domain,
                items: [ServerPicker.Item(
                    id: $0.domain,
                    title: $0.domain,
                    totalUsers: $0.totalUsers,
                    lastWeekUsers: $0.lastWeekUsers,
                    description: $0.description,
                    coverImageURL: $0.proxiedThumbnail ?? "")])
            snapshot.appendSections([section])
            snapshot.appendItems(section.items)
        }
        
        dataSource?.apply(snapshot)
    }
}

extension ServerPickerDataSource {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        if searchText == "" {
            apply(items: items)
            return
        }
        let filteredItems = items.filter { $0.domain.contains(searchText.lowercased()) }
        apply(items: filteredItems)
    }
}
