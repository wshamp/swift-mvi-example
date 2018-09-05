//
//  CircularMaskImageView.swift
//  WDCommon
//
//  Created by Wyeth Shamp on 7/10/17.
//  Copyright © 2018 wyethshamp All rights reserved.
//

import UIKit

@IBDesignable
public class CircularMaskImageView: UIImageView {
    private let maskPathInset: CGFloat = 0.5
    @IBInspectable public var lineWidth: CGFloat = 3.0 {
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable public var ovalPathInset: CGFloat = 1.5 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override public var frame: CGRect {
        didSet {
            setNeedsLayout()
        }
    }
    
    lazy var maskLayer: CAShapeLayer = {
        let maskLayer = CAShapeLayer()
        //The mask needs to be smaller than the border because otherwise the image bleeds over the border
        maskLayer.path = UIBezierPath(ovalIn: self.bounds.insetBy(dx: maskPathInset, dy: maskPathInset)).cgPath
        return maskLayer
    }()
    
    lazy var ovalLayer: CAShapeLayer = {
        let ovalLayer = CAShapeLayer()
        ovalLayer.frame = self.bounds
        ovalLayer.path = UIBezierPath(ovalIn: self.bounds.insetBy(dx: self.ovalPathInset, dy: self.ovalPathInset)).cgPath
        ovalLayer.lineWidth = 3.0
        ovalLayer.strokeColor = UIColor.white.cgColor
        ovalLayer.fillColor = nil
        return ovalLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        maskLayer.path = UIBezierPath(ovalIn: self.bounds.insetBy(dx: 0.5, dy: 0.5)).cgPath
        ovalLayer.path = UIBezierPath(ovalIn: self.bounds.insetBy(dx: 1.5, dy: 1.5)).cgPath
    }
    
    private func setup() {
        layer.masksToBounds = true
        layer.mask = maskLayer
        layer.addSublayer(ovalLayer)
    }
    
}
