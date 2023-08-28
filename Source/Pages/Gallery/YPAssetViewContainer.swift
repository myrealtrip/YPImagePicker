//
//  YPAssetViewContainer.swift
//  YPImagePicker
//
//  Created by Sacha Durand Saint Omer on 15/11/2016.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

/// The container for asset (video or image). It containts the YPGridView and YPAssetZoomableView.
final class YPAssetViewContainer: UIView {
    public var zoomableView: YPAssetZoomableView
    public var itemOverlay: UIView?
    public let curtain = UIView()
    public let curtainView = YPCurtainView()
    public let spinnerView = UIView()
    public let squareCropButton: UIButton = {
        let v = UIButton()
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        
        let image = imageFromBundle("ico_expand_content")
        v.setImage(image.withTintColor(YPConfig.colors.buttonImageColorForNormal), for: .normal)
        v.setImage(image.withTintColor(YPConfig.colors.buttonImageColorForSelected), for: .selected)
        v.setBackgroundColor(YPConfig.colors.buttonBackgroundColorForNormal, forState: .normal)
        v.setBackgroundColor(YPConfig.colors.buttonBackgroundColorForSelected, forState: .selected)
        return v
    }()
    public let multipleSelectionButton: UIButton = {
        let v = UIButton()
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        v.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10+6+4)
        v.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6-4)
        
        let image = imageFromBundle("ico_select_library")
        v.setImage(image.withTintColor(YPConfig.colors.buttonImageColorForNormal), for: .normal)
        v.setImage(image.withTintColor(YPConfig.colors.buttonImageColorForSelected), for: .selected)
        v.setTitle("여러장 선택", for: .normal)
        v.setTitle("여러장 선택", for: .selected)
        v.setTitleColor(YPConfig.colors.buttonImageColorForNormal, for: .normal)
        v.setTitleColor(YPConfig.colors.buttonImageColorForSelected, for: .selected)
        v.titleLabel?.font = YPConfig.fonts.buttonTitleFont
        
        v.setBackgroundColor(YPConfig.colors.buttonBackgroundColorForNormal, forState: .normal)
        v.setBackgroundColor(YPConfig.colors.buttonBackgroundColorForSelected, forState: .selected)
        return v
    }()
    public var onlySquare = YPConfig.library.onlySquare
    public var isShown = true
    public var spinnerIsShown = false
    
    private let spinner = UIActivityIndicatorView(style: .medium)
    private var shouldCropToSquare = YPConfig.library.isSquareByDefault
    private var isMultipleSelectionEnabled = false

    public var itemOverlayType = YPConfig.library.itemOverlayType

    init(frame: CGRect, zoomableView: YPAssetZoomableView) {
        self.zoomableView = zoomableView
        super.init(frame: frame)

        self.zoomableView.zoomableViewDelegate = self

        switch itemOverlayType {
        case .grid:
            itemOverlay = YPGridView()
        default:
            break
        }

        if let itemOverlay = itemOverlay {
            addSubview(itemOverlay)
            itemOverlay.frame = frame
            clipsToBounds = true

            itemOverlay.alpha = 0
        }

        let touchDownGR = UILongPressGestureRecognizer(target: self,
                                                       action: #selector(handleTouchDown))
        touchDownGR.minimumPressDuration = 0
        touchDownGR.delegate = self
        addGestureRecognizer(touchDownGR)

        // TODO: Add tap gesture to play/pause. Add double tap gesture to square/unsquare

        subviews(
            spinnerView.subviews(
                spinner
            ),
            curtain,
            curtainView
        )

        spinner.centerInContainer()
        spinnerView.fillContainer()
        curtain.fillContainer()
        curtainView.fillContainer()

        spinner.startAnimating()
        spinnerView.backgroundColor = UIColor.ypLabel.withAlphaComponent(0.3)
        curtain.backgroundColor = UIColor.ypLabel.withAlphaComponent(0.7)
        curtain.alpha = 0
        curtainView.isHidden = !YPConfig.library.fixCropAreaUsingAspectRatio

        if !onlySquare {
            // Crop Button
            subviews(squareCropButton)
            squareCropButton.size(36)
            |-12-squareCropButton
            squareCropButton.Bottom == self.Bottom - 12
        }

        // Multiple selection button
        subviews(multipleSelectionButton)
        multipleSelectionButton.height(36).trailing(12)
        multipleSelectionButton.Bottom == self.Bottom - 12
    }

    required init?(coder: NSCoder) {
        zoomableView = YPAssetZoomableView()
        super.init(coder: coder)
        fatalError("Only code layout.")
    }

    // MARK: - Square button

    @objc public func squareCropButtonTapped() {
        squareCropButton.isSelected.toggle()
        if YPConfig.library.fixCropAreaUsingAspectRatio {
            let fit = squareCropButton.isSelected
            updateCurtainView(ratio: fit ? 1 : zoomableView.fixedAspectRatio)
            zoomableView.fitImage_fixed(fit, animated: true)
        } else {
            let z = zoomableView.zoomScale
            shouldCropToSquare = (z >= 1 && z < zoomableView.squaredZoomScale)
            zoomableView.fitImage(shouldCropToSquare, animated: true)
        }
    }

    /// Update only UI of square crop button.
    public func updateSquareCropButtonState() {
        guard !isMultipleSelectionEnabled else {
            // If multiple selection enabled, the squareCropButton is not visible
            squareCropButton.isHidden = true
            return
        }
        guard !onlySquare else {
            // If only square enabled, than the squareCropButton is not visible
            squareCropButton.isHidden = true
            return
        }
        guard let selectedAssetImage = zoomableView.assetImageView.image else {
            // If no selected asset, than the squareCropButton is not visible
            squareCropButton.isHidden = true
            return
        }

        let isImageASquare = selectedAssetImage.size.width == selectedAssetImage.size.height
        squareCropButton.isHidden = isImageASquare
    }
    
    // MARK: - Multiple selection

    /// Use this to update the multiple selection mode UI state for the YPAssetViewContainer
    public func setMultipleSelectionMode(on: Bool) {
        isMultipleSelectionEnabled = on
        multipleSelectionButton.isSelected = on
        updateSquareCropButtonState()
        zoomableView.isMultipleSelectionEnabled = isMultipleSelectionEnabled
    }
    
    public func updateCurtainView(ratio: CGFloat?) {
        guard isMultipleSelectionEnabled == false else { return }
        curtainView.updateCropAreaSize(ratio: ratio)
    }
}

// MARK: - ZoomableViewDelegate
extension YPAssetViewContainer: YPAssetZoomableViewDelegate {
    public func ypAssetZoomableViewDidLayoutSubviews(_ zoomableView: YPAssetZoomableView) {
        let newFrame = zoomableView.assetImageView.convert(zoomableView.assetImageView.bounds, to: self)
        
        if let itemOverlay = itemOverlay {
            // update grid position
            itemOverlay.frame = frame.intersection(newFrame)
            itemOverlay.layoutIfNeeded()
        }
        
        // Update play imageView position - bringing the playImageView from the videoView to assetViewContainer,
        // but the controll for appearing it still in videoView.
        if zoomableView.videoView.playImageView.isDescendant(of: self) == false {
            self.addSubview(zoomableView.videoView.playImageView)
            zoomableView.videoView.playImageView.centerInContainer()
        }
    }
    
    public func ypAssetZoomableViewScrollViewDidZoom() {
        guard let itemOverlay = itemOverlay else {
            return
        }
        if isShown {
            UIView.animate(withDuration: 0.1) {
                itemOverlay.alpha = 1
            }
        }
    }
    
    public func ypAssetZoomableViewScrollViewDidEndZooming() {
        guard let itemOverlay = itemOverlay else {
            return
        }
        UIView.animate(withDuration: 0.3) {
            itemOverlay.alpha = 0
        }
    }
}

// MARK: - Gesture recognizer Delegate
extension YPAssetViewContainer: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith
        otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !spinnerIsShown && !(touch.view is UIButton)
    }
    
    @objc
    private func handleTouchDown(sender: UILongPressGestureRecognizer) {
        guard let itemOverlay = itemOverlay else {
            return
        }
        switch sender.state {
        case .began:
            if isShown {
                UIView.animate(withDuration: 0.1) {
                    itemOverlay.alpha = 1
                }
            }
        case .ended:
            UIView.animate(withDuration: 0.3) {
                itemOverlay.alpha = 0
            }
        default: ()
        }
    }
}
