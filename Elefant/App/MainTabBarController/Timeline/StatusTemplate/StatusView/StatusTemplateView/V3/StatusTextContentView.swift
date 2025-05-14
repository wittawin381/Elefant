//
//  StatusTextContentView.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 10/5/2568 BE.
//

import Foundation
import UIKit
import HTMLParser

class StatusTextContentView: UIView {
    private let textView = UITextView()
    private var appliedConfiguration: Configuration
    
    struct Configuration: UIContentConfiguration {
        let content: Content
        
        func makeContentView() -> any UIView & UIContentView {
            StatusTextContentView(configuration: self)
        }
        
        func updated(for state: any UIConfigurationState) -> StatusTextContentView.Configuration {
            self
        }
    }
    
    init(configuration: Configuration) {
        appliedConfiguration = configuration
        super.init(frame: .zero)
        apply(configuration: configuration)
        setupLayout()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        layoutMargins = UIEdgeInsets(
            top: 8,
            left: StatusViewConfiguration.padding,
            bottom: 0,
            right: StatusViewConfiguration.padding)
        
        addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: StatusViewConfiguration.defaultContentLeadingSpacing),
            textView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            textView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo:layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    private func setupView() {
        textView.sizeToFit()
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 14, weight: .regular)
        textView.isEditable = false
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        isUserInteractionEnabled = false
    }
}

extension StatusTextContentView: UIContentView {
    var configuration: any UIContentConfiguration {
        get { appliedConfiguration }
        set(newValue) {
            guard let configuration = newValue as? Configuration else { return }
            apply(configuration: configuration)
        }
    }
    
    private func apply(configuration: Configuration) {
        appliedConfiguration = configuration
        
        let contentBuilder = HTMLAttributedStringContentBuilder { tag in
            switch tag {
            case .p: [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.label,
            ]
            case .a: [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.link,
            ]
            case .span: [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.label,
            ]
            case ._unknown: [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.label,
            ]
            }
        }
        textView.attributedText = configuration.content.createFormattedOutput(using: contentBuilder)
        superview?.isUserInteractionEnabled = false
    }
}
