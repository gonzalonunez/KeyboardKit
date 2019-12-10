//
//  ScrollableLabel.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2019-12-09.
//  Copyright © 2019 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This is the default label that will be used by autocomplete
 toolbars if no other view builder function is provided.
 
 This is not a label, but rather a composite view that has a
 scroll view with an embedded label.
 
 This view mimics the native iOS autocomplete label and will
 enable scrolling if the textual content is too large to fit
 the label.
 
 `TODO` - Center text until scrolling.
 `TODO` - Implement separator lines.
 `TODO` - Implement horizontal blur.
 */
open class AutocompleteToolbarLabel: UIView {
    
    
    // MARK: - Initialization
    
    public convenience init(text: String, textDocumentProxy: UITextDocumentProxy) {
        self.init()
        self.text = text
        self.textDocumentProxy = textDocumentProxy
        accessibilityTraits = .button
        addSubview(scrollView, fill: true)
        addTapAction { [weak self] in
            guard let self = self else { return }
            self.textDocumentProxy?.replaceCurrentWord(with: text)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async {
            self.scrollToEndIfNeeded()
        }
    }
    
    
    // MARK: - Properties
    
    public var text: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    private weak var textDocumentProxy: UITextDocumentProxy?
    
    public var textMargins: CGFloat = 8 {
        didSet {
            scrollView.contentInset.left = textMargins
            scrollView.contentInset.right = textMargins
        }
    }
    
    private var hasPerformedScrollToEnd = false
    
    
    // MARK: - Views
    
    public lazy var label: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.addSubview(label, fill: true)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentInset = .init(top: 0, left: textMargins, bottom: 0, right: textMargins)
        view.heightAnchor.constraint(equalTo: label.heightAnchor, multiplier: 1).isActive = true
        return view
    }()
    
    
    
    // MARK: - Functions
    
    public func scrollToEndIfNeeded() {
        if hasPerformedScrollToEnd { return }
        hasPerformedScrollToEnd = true
        guard scrollView.contentSize.width > scrollView.frame.size.width else { return }
        let contentWidth = scrollView.contentSize.width
        let frameWidth = scrollView.frame.size.width
        let offset = contentWidth - frameWidth + textMargins
        scrollView.contentOffset.x = offset
    }
    
    private func setupAlphaMask() {
        let gradient = CAGradientLayer()
        gradient.frame = scrollView.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.0, 0.1, 0.5, 0.9, 1.0]
        scrollView.layer.mask = gradient
    }
}
