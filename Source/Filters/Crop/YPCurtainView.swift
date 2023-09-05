//
//  YPCurtainView.swift
//  YPImagePicker
//
//  Created by 홍세영 on 2023/07/27.
//  Copyright © 2023 Yummypets. All rights reserved.
//

import UIKit

final class YPCurtainView: UIView {
    
    let topCurtainView = UIView()
    let bottomCurtainView = UIView()
    let leadingCurtainView = UIView()
    let trailingCurtainView = UIView()
    let cropAreaView = UIView()
    
    convenience init() {
        self.init(frame: .zero)
        
        setupLayout()
        
        self.clipsToBounds = true
        self.isUserInteractionEnabled = false
        
        topCurtainView.backgroundColor = YPConfig.colors.assetViewBackgroundColor
        bottomCurtainView.backgroundColor = YPConfig.colors.assetViewBackgroundColor
        leadingCurtainView.backgroundColor = YPConfig.colors.assetViewBackgroundColor
        trailingCurtainView.backgroundColor = YPConfig.colors.assetViewBackgroundColor
    }
    
    func updateCropAreaSize(ratio: CGFloat?) {
        guard let ratio else { return }
        
        let screenWidth = YPImagePickerConfiguration.screenWidth
        if ratio < 1 {
            cropAreaView.widthConstraint?.constant = screenWidth
            cropAreaView.heightConstraint?.constant = screenWidth * ratio
        } else if ratio > 1 {
            cropAreaView.widthConstraint?.constant = screenWidth * (1 / ratio)
            cropAreaView.heightConstraint?.constant = screenWidth
        } else {
            cropAreaView.widthConstraint?.constant = screenWidth
            cropAreaView.heightConstraint?.constant = screenWidth
        }
    }
}

private extension YPCurtainView {
    func setupLayout() {
        subviews(
            topCurtainView,
            leadingCurtainView,
            trailingCurtainView,
            bottomCurtainView,
            cropAreaView
        )
        
        topCurtainView.height(>=0)
        bottomCurtainView.height(>=0)
        leadingCurtainView.width(>=0)
        trailingCurtainView.width(>=0)
        
        leadingCurtainView.Top == topCurtainView.Bottom
        leadingCurtainView.Bottom == bottomCurtainView.Top
        
        trailingCurtainView.Top == topCurtainView.Bottom
        trailingCurtainView.Bottom == bottomCurtainView.Top
        
        cropAreaView.Top == topCurtainView.Bottom
        cropAreaView.Bottom == bottomCurtainView.Top
        
        |leadingCurtainView--0--cropAreaView--0--trailingCurtainView|
        
        layout(
            0,
            |topCurtainView|,
            |cropAreaView|,
            |bottomCurtainView|,
            0
        )
        
        let screenWidth = YPImagePickerConfiguration.screenWidth
        cropAreaView.width(screenWidth).height(screenWidth)
        
        cropAreaView.centerVertically()
        cropAreaView.centerHorizontally()
    }
}

private extension UIView {
    var widthConstraint: NSLayoutConstraint? {
        return YPHelper.constraintForView(self, attribute: .width)
    }
    
    var heightConstraint: NSLayoutConstraint? {
        return YPHelper.constraintForView(self, attribute: .height)
    }
}
