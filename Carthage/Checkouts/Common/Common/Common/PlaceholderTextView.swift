//
//  PlaceholderTextView.swift
//  WDCommon
//
//  Created by Wyeth Shamp on 2/15/16.
//  Copyright © 2018 wyethshamp All rights reserved.
//

import UIKit

public class PlaceholderTextView: UITextView {
    
    lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = self.font
        label.textColor = UIColor(red: 155/255.0, green: 169/255.0, blue: 179/255.0, alpha: 1)
        label.textAlignment = self.textAlignment
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    @IBInspectable final public var placeholderLabelText: String = "" {
        didSet {
            placeholderLabel.text = placeholderLabelText
        }
    }
    
    override public var text: String! {
        willSet {
            self.placeholderLabel.isHidden = !newValue.isEmpty
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(PlaceholderTextView.textChanged),
                                               name: NSNotification.Name.UITextViewTextDidChange,
                                               object: nil)
        self.textContainerInset = UIEdgeInsetsMake(8, 4, 8, 4)
        setupPlaceholder()
        self.clipsToBounds = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UITextViewTextDidChange,
                                                  object: nil)
    }
    
    @objc private func textChanged() {
        self.placeholderLabel.isHidden = !self.text.isEmpty
    }
    
    private func setupPlaceholder() {
        self.addSubview(placeholderLabel)
        
        let topConstraint = NSLayoutConstraint(
            item: placeholderLabel,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1,
            constant: textContainerInset.top)
        self.addConstraint(topConstraint)
        
        let bottomConstraint = NSLayoutConstraint(
            item: placeholderLabel,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1,
            constant: textContainerInset.bottom * -1)
        self.addConstraint(bottomConstraint)
        
        let leadingConstraint = NSLayoutConstraint(
            item: placeholderLabel,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1,
            constant: textContainerInset.left + textContainer.lineFragmentPadding)
        self.addConstraint(leadingConstraint)
        
        let trailingConstraint = NSLayoutConstraint(
            item: placeholderLabel,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1,
            constant: (textContainerInset.right + textContainer.lineFragmentPadding) * -1)
        self.addConstraint(trailingConstraint)
        
        
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.preferredMaxLayoutWidth = textContainer.size.width - (textContainer.lineFragmentPadding * 2)
    }
}
