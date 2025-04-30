//
//  OnboardingViewController.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 2/4/2568 BE.
//

import Foundation
import UIKit
import ElefantEntity

@MainActor protocol OnboardingViewControllerDelegate: AnyObject {
    func onboardingViewControllerDidTapStartButton(_ viewController: OnboardingViewController)
}

class OnboardingViewController: UIViewController {
    weak var delegate: OnboardingViewControllerDelegate?
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    } ()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Start", for: .normal)
        button.setTitleColor(.tintColor, for: .normal)
        return button
    } ()
    
    private let addKeychainButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add", for: .normal)
        button.setTitleColor(.tintColor, for: .normal)
        return button
    } ()
    
    private let deleteKeychainButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Remove", for: .normal)
        return button
    } ()
    
    private let allKeychainButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Alll", for: .normal)
        return button
    } ()
    
    private var keychain = Keychain()
    
    override func viewDidLoad() {
        setupLayout()
        setupView()
        
    }
    
    private func setupLayout() {
        view.addSubview(iconImageView)
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 120),
            iconImageView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        view.addSubview(startButton)
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 32),
        ])
        
        view.addSubview(addKeychainButton)
        NSLayoutConstraint.activate([
            addKeychainButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 16),
        ])
        
        view.addSubview(deleteKeychainButton)
        NSLayoutConstraint.activate([
            deleteKeychainButton.topAnchor.constraint(equalTo: addKeychainButton.bottomAnchor, constant: 16),
        ])
        
        view.addSubview(allKeychainButton)
        NSLayoutConstraint.activate([
            allKeychainButton.topAnchor.constraint(equalTo: deleteKeychainButton.bottomAnchor, constant: 16),
        ])
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        startButton.addTarget(self, action: #selector(startButtonDidTap), for: .touchUpInside)
        addKeychainButton.addTarget(self, action: #selector(addKeyChainButtonDidTap), for: .touchUpInside)
        deleteKeychainButton.addTarget(self, action: #selector(deleteKeyChainButtonDidTap), for: .touchUpInside)
        allKeychainButton.addTarget(self, action: #selector(allKeychainButtonDidTap), for: .touchUpInside)
    }
    
    @objc private func startButtonDidTap() {
        delegate?.onboardingViewControllerDidTapStartButton(self)
    }
    
    @objc private func addKeyChainButtonDidTap() {
        let token = Token(accessToken: "accessToken", tokenType: "Bearer", scope: "scope", createdAt: 0)
        Task {
            let result = await keychain.set(token, for: UUID().uuidString)
        }
    }
    
    @objc private func deleteKeyChainButtonDidTap() {
        Task {
            await keychain.removeAll()
        }
    }
    
    @objc private func allKeychainButtonDidTap() {
        Task {
            let data = await keychain.allData
            print(data)
            let value = await keychain.getData(for: "2D399697-9A7D-4C3F-AF7F-6727768ADABB")
            print(value)
        }
    }
}
