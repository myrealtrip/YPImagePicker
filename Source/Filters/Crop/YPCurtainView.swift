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
        
        setupLayout(ratio: ratio ?? 1)
        
        self.isUserInteractionEnabled = false
        
        topCurtainView.backgroundColor = .black
        bottomCurtainView.backgroundColor = .black
        leadingCurtainView.backgroundColor = .black
        trailingCurtainView.backgroundColor = .black
    }
}

private extension YPCurtainView {
    func setupLayout(ratio: Float) {
        subviews(
            topCurtainView,
            leadingCurtainView,
            trailingCurtainView,
            bottomCurtainView,
            cropAreaView
        )
        
//        topCurtainView.height(>=0)
//        bottomCurtainView.height(>=0)
//        leadingCurtainView.height(>=0)
//        trailingCurtainView.height(>=0)
        
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
    }
}
