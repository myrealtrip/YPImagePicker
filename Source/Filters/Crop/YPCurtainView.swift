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
    
    convenience init(ratio: Float?) {
        self.init(frame: .zero)
        
        setupLayout()
        updateCropAreaSize(ratio: ratio ?? 1)
        
        self.clipsToBounds = true
        self.isUserInteractionEnabled = false
        
        topCurtainView.backgroundColor = YPConfig.colors.assetViewBackgroundColor
        bottomCurtainView.backgroundColor = YPConfig.colors.assetViewBackgroundColor
        leadingCurtainView.backgroundColor = YPConfig.colors.assetViewBackgroundColor
        trailingCurtainView.backgroundColor = YPConfig.colors.assetViewBackgroundColor
    }
    
    func updateCropAreaSize(ratio: Float) {
        let screenWidth = Float(YPImagePickerConfiguration.screenWidth)
        if ratio < 1 {
            cropAreaView.width(CGFloat(screenWidth))
            cropAreaView.height(CGFloat(screenWidth * ratio))
        } else if ratio > 1 {
            cropAreaView.width(CGFloat(screenWidth * (1 / ratio)))
            cropAreaView.height(CGFloat(screenWidth))
        } else {
            cropAreaView.width(CGFloat(screenWidth)).height(CGFloat(screenWidth))
        }
        
        setNeedsLayout()
        layoutIfNeeded()
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
        
        cropAreaView.centerVertically()
        cropAreaView.centerHorizontally()
    }
}
