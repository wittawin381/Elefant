//
//  LoadMoreView.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 15/4/2568 BE.
//

import Foundation
import UIKit

struct LoadMoreViewConfiguration: UIContentConfiguration {
    func makeContentView() -> any UIView & UIContentView {
        LoadMoreView()
    }
    
    func updated(for state: any UIConfigurationState) -> LoadMoreViewConfiguration {
        self
    }
}

class LoadMoreView: UIView {
    private let activityIndicatorView = UIActivityIndicatorView(style: .medium)
    private let appiedConfiguration = LoadMoreViewConfiguration()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimating() {
        activityIndicatorView.startAnimating()
    }
    
    func stopAnimating() {
        activityIndicatorView.stopAnimating()
    }
    
    private func setupLayout() {
        addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            activityIndicatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
}

extension LoadMoreView: UIContentView {
    var configuration: any UIContentConfiguration {
        get { appiedConfiguration }
        set(newValue) { }
    }
}
