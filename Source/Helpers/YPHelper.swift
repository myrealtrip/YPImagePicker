//
//  YPHelper.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 02/11/16.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import Foundation
import UIKit
import Photos

internal func ypLocalized(_ str: String) -> String {
    return NSLocalizedString(str,
                             tableName: "YPImagePickerLocalizable",
                             bundle: Bundle.local,
                             value: "",
                             comment: "")
}

internal func imageFromBundle(_ named: String) -> UIImage {
    return UIImage(named: named, in: Bundle.local, compatibleWith: nil) ?? UIImage()
}

struct YPHelper {
    static func changeBackButtonIcon(_ controller: UIViewController) {
        if YPConfig.icons.shouldChangeDefaultBackButtonIcon {
            let backButtonIcon = YPConfig.icons.backButtonIcon
            controller.navigationController?.navigationBar.backIndicatorImage = backButtonIcon
            controller.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backButtonIcon
        }
    }
    
    static func changeBackButtonTitle(_ controller: UIViewController) {
        if YPConfig.icons.hideBackButtonTitle {
            controller.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                          style: .plain,
                                                                          target: nil,
                                                                          action: nil)
        }
    }
    
    static func configureFocusView(_ v: UIView) {
        v.alpha = 0.0
        v.backgroundColor = UIColor.clear
        v.layer.borderColor = UIColor.ypSecondaryLabel.cgColor
        v.layer.borderWidth = 1.0
        v.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    static func animateFocusView(_ v: UIView) {
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 3.0, options: UIView.AnimationOptions.curveEaseIn,
                       animations: {
                        v.alpha = 1.0
                        v.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }, completion: { _ in
            v.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            v.removeFromSuperview()
        })
    }
    
    static func formattedStrigFrom(_ timeInterval: TimeInterval) -> String {
        let interval = Int(timeInterval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    static func constraintForView(_ v: UIView, attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        
        func lookForConstraint(in view: UIView?) -> NSLayoutConstraint? {
            guard let constraints = view?.constraints else {
                return nil
            }
            for c in constraints {
                if let fi = c.firstItem as? NSObject, fi == v && c.firstAttribute == attribute {
                    return c
                } else if let si = c.secondItem as? NSObject, si == v && c.secondAttribute == attribute {
                    return c
                }
            }
            return nil
        }
        
        // Width and height constraints added via widthAnchor/heightAnchors are
        // added on the view itself.
        if (attribute == .width || attribute == .height) {
            return lookForConstraint(in: v.superview) ?? lookForConstraint(in: v)
        }
        
        // Look for constraint on superview.
        return lookForConstraint(in: v.superview)
    }
}
