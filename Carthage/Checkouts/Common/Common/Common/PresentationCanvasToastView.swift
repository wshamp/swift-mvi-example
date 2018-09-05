//
//  PresentationCanvasToastView.swift
//  WDCommon
//
//  Created by Wyeth Shamp on 7/6/17.
//  Copyright © 2018 wyethshamp All rights reserved.
//

import Foundation
import UIKit

public class PresentationCanvasToastView : UIView {
    public var shadowColor: UIColor = .black
    public var shadowOffset: CGSize = CGSize(width: 0.0, height: 4.0)
    public var shadowOpacity: Float = 0.33
    public var labelLineHeight: Float = 17.0
    
    var text: String?
    var accessoryView: UIView?
    
    public init(frame: CGRect, text: String, accessoryView: UIView?) {
        super.init(frame: frame)
        self.text = text
        self.accessoryView = accessoryView
        backgroundColor = .white
        var leftAnchor = leadingAnchor
        if let accessoryView = accessoryView {
            layoutAccessoryView(accessoryView: accessoryView)
            leftAnchor = accessoryView.trailingAnchor
        }
        
        let label = makeLabel(text: text)
        layoutLabel(label: label, leftAnchor: leftAnchor)
        
        applyDropShadow()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func layoutAccessoryView(accessoryView: UIView) {
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(accessoryView)
        accessoryView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0).isActive = true
        accessoryView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func makeLabel(text: String?) -> UILabel {
        let label = UILabel(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(0), height: CGFloat(labelLineHeight)))
        label.text = text
        if let robotoFont = UIFont(name: "Roboto-Regular", size: 14) {
            label.font = robotoFont
        }
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = Int(self.frame.height / CGFloat(labelLineHeight))
        return label
    }
    
    func layoutLabel(label: UILabel, leftAnchor: NSLayoutXAxisAnchor) {
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.leadingAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        label.setContentHuggingPriority(.init(249), for: .horizontal)
        
    }
    
    func applyDropShadow() {
        let shadowPath = UIBezierPath(rect: bounds)
        layer.masksToBounds = false
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
}
