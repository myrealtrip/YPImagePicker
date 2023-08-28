//
//  YPAssetZoomableView.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 2015/11/16.
//  Edited by Nik Kov || nik-kov.com on 2018/04
//  Copyright © 2015 Yummypets. All rights reserved.
//

import UIKit
import Photos

protocol YPAssetZoomableViewDelegate: AnyObject {
    func ypAssetZoomableViewDidLayoutSubviews(_ zoomableView: YPAssetZoomableView)
    func ypAssetZoomableViewScrollViewDidZoom()
    func ypAssetZoomableViewScrollViewDidEndZooming()
}

final class YPAssetZoomableView: UIScrollView {
    public weak var zoomableViewDelegate: YPAssetZoomableViewDelegate?
    public var cropAreaDidChange = {}
    public var isVideoMode = false
    public var photoImageView = UIImageView()
    public var videoView = YPVideoView()
    public var squaredZoomScale: CGFloat = 1
    public var minWidthForItem: CGFloat? = YPConfig.library.minWidthForItem
    public var landscapeAspectRatio: CGFloat? = YPConfig.library.landscapeAspectRatio
    public var portraitAspectRatio: CGFloat? = YPConfig.library.portraitAspectRatio
    public var fixedAspectRatio: CGFloat = 1
    public var initialFixedAspectRatio: CGFloat? = YPConfig.library.initialFixedAspectRatio
    public var isMultipleSelectionEnabled = false
    
    fileprivate var currentAsset: PHAsset?
    
    // Image view of the asset for convenience. Can be video preview image view or photo image view.
    public var assetImageView: UIImageView {
        return isVideoMode ? videoView.previewImageView : photoImageView
    }

    /// Set zoom scale to fit the image to square or show the full image
    //
    /// - Parameters:
    ///   - fit: If true - zoom to show squared. If false - show full.
    public func fitImage(_ fit: Bool, animated isAnimated: Bool = false) {
        squaredZoomScale = calculateSquaredZoomScale()
        if fit {
            setZoomScale(squaredZoomScale, animated: isAnimated)
        } else {
            setZoomScale(1, animated: isAnimated)
        }
    }
    
    /// Re-apply correct scrollview settings if image has already been adjusted in
    /// multiple selection mode so that user can see where they left off.
    public func applyStoredCropPosition(_ scp: YPLibrarySelection) {
        // ZoomScale needs to be set first.
        if let zoomScale = scp.scrollViewZoomScale {
            setZoomScale(zoomScale, animated: false)
        }
        if let contentOffset = scp.scrollViewContentOffset {
            setContentOffset(contentOffset, animated: false)
        }
    }
    
    public func setVideo(_ video: PHAsset,
                         mediaManager: LibraryMediaManager,
                         storedCropPosition: YPLibrarySelection?,
                         completion: @escaping () -> Void,
                         updateCropInfo: @escaping () -> Void) {
        mediaManager.imageManager?.fetchPreviewFor(video: video) { [weak self] preview in
            guard let strongSelf = self else { return }
            guard strongSelf.currentAsset != video else { completion() ; return }
            
            if strongSelf.videoView.isDescendant(of: strongSelf) == false {
                strongSelf.isVideoMode = true
                strongSelf.photoImageView.removeFromSuperview()
                strongSelf.addSubview(strongSelf.videoView)
            }
            
            strongSelf.videoView.setPreviewImage(preview)
            
            strongSelf.setAssetFrame(for: strongSelf.videoView, with: preview)

            strongSelf.squaredZoomScale = strongSelf.calculateSquaredZoomScale()
            
            completion()
            
            // Stored crop position in multiple selection
            if let scp173 = storedCropPosition {
                strongSelf.applyStoredCropPosition(scp173)
                // MARK: add update CropInfo after multiple
                updateCropInfo()
            }
        }
        mediaManager.imageManager?.fetchPlayerItem(for: video) { [weak self] playerItem in
            guard let strongSelf = self else { return }
            guard strongSelf.currentAsset != video else { completion() ; return }
            strongSelf.currentAsset = video

            strongSelf.videoView.loadVideo(playerItem)
            strongSelf.videoView.play()
            strongSelf.zoomableViewDelegate?.ypAssetZoomableViewDidLayoutSubviews(strongSelf)
        }
    }
    
    public func setImage(_ photo: PHAsset,
                         mediaManager: LibraryMediaManager,
                         storedCropPosition: YPLibrarySelection?,
                         completion: @escaping (Bool) -> Void,
                         updateCropInfo: @escaping () -> Void,
                         forceChange: Bool = false) {
        guard currentAsset != photo || forceChange else {
            DispatchQueue.main.async { completion(false) }
            return
        }
        currentAsset = photo
        
        mediaManager.imageManager?.fetch(photo: photo) { [weak self] image, isLowResIntermediaryImage in
            guard let strongSelf = self else { return }
            
            if strongSelf.photoImageView.isDescendant(of: strongSelf) == false {
                strongSelf.isVideoMode = false
                strongSelf.videoView.removeFromSuperview()
                strongSelf.videoView.showPlayImage(show: false)
                strongSelf.videoView.deallocate()
                strongSelf.addSubview(strongSelf.photoImageView)
            
                strongSelf.photoImageView.contentMode = .scaleAspectFill
                strongSelf.photoImageView.clipsToBounds = true
            }
            
            strongSelf.photoImageView.image = image
           
            strongSelf.setAssetFrame(for: strongSelf.photoImageView, with: image)
                
            // Stored crop position in multiple selection
            if let scp173 = storedCropPosition {
                strongSelf.applyStoredCropPosition(scp173)
                // add update CropInfo after multiple
                updateCropInfo()
            }

            strongSelf.squaredZoomScale = strongSelf.calculateSquaredZoomScale()
            
            completion(isLowResIntermediaryImage)
        }
    }

    public func clearAsset() {
        isVideoMode = false
        videoView.removeFromSuperview()
        videoView.deallocate()
        photoImageView.removeFromSuperview()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = YPConfig.colors.assetViewBackgroundColor
        clipsToBounds = true
        photoImageView.frame = CGRect(origin: CGPoint.zero, size: CGSize.zero)
        videoView.frame = CGRect(origin: CGPoint.zero, size: CGSize.zero)
        maximumZoomScale = 6.0
        minimumZoomScale = 1
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        delegate = self
        alwaysBounceHorizontal = true
        alwaysBounceVertical = true
        isScrollEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        fatalError("Only code layout.")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        zoomableViewDelegate?.ypAssetZoomableViewDidLayoutSubviews(self)
    }
}

// MARK: - Private

fileprivate extension YPAssetZoomableView {
    
    func fitImageAtFixedRatio(`for` view: UIView, with image: UIImage) {
        // Reseting the previous scale
        self.minimumZoomScale = 1
        self.zoomScale = 1
        self.contentInset = .zero
        
        let screenWidth = YPImagePickerConfiguration.screenWidth
        
        let w = image.size.width
        let h = image.size.height
        
        if fixedAspectRatio < 1 {   // 가로
            let offset = (screenWidth * (1 - fixedAspectRatio)) / 2
            if w > h {
                view.frame.size.width = screenWidth * fixedAspectRatio * (w / h)
                view.frame.size.height = screenWidth * fixedAspectRatio
            } else if h > w {
                view.frame.size.width = screenWidth
                view.frame.size.height = screenWidth * (h / w)
                self.contentInset.top = offset
                self.contentInset.bottom = offset
            } else {
                view.frame.size.width = screenWidth
                view.frame.size.height = screenWidth
                self.contentInset.top = offset
                self.contentInset.bottom = offset
            }
        } else if fixedAspectRatio > 1 { // 세로
            let offset = (screenWidth * (1 - 1 / fixedAspectRatio)) / 2
            if w > h {
                view.frame.size.width = screenWidth * (w / h)
                view.frame.size.height = screenWidth
                self.contentInset.left = offset
                self.contentInset.right = offset
            } else if h > w {
                view.frame.size.width = screenWidth * (1 / fixedAspectRatio)
                view.frame.size.height = screenWidth * (1 / fixedAspectRatio) * (h / w)
            } else {
                view.frame.size.width = screenWidth
                view.frame.size.height = screenWidth
                self.contentInset.top = offset
                self.contentInset.bottom = offset
            }
        } else {
            if w > h {
                view.frame.size.width = screenWidth * (w / h)
                view.frame.size.height = screenWidth
            } else if h > w {
                view.frame.size.width = screenWidth
                view.frame.size.height = screenWidth * (h / w)
            } else {
                view.frame.size.width = screenWidth
                view.frame.size.height = screenWidth
            }
        }

        view.center = center
        centerAssetView_fixed()
    }
    
    func setAssetFrame(`for` view: UIView, with image: UIImage) {

        if YPConfig.library.fixCropAreaUsingAspectRatio {
            if let initialFixedAspectRatio {
                fixedAspectRatio = initialFixedAspectRatio
                fitImageAtFixedRatio(for: view, with: image)
                return
            }
            
            if isMultipleSelectionEnabled {
                fitImageAtFixedRatio(for: view, with: image)
                return
            }
            setAssetFrame_fixed(for: view, with: image)
            return
        }
        
        setAssetFrame_original(for: view, with: image)
    }
    
    func setAssetFrame_original(`for` view: UIView, with image: UIImage) {
        // Reseting the previous scale
        self.minimumZoomScale = 1
        self.zoomScale = 1
        
        // Calculating and setting the image view frame depending on screenWidth
        let screenWidth = YPImagePickerConfiguration.screenWidth
        
        let w = image.size.width
        let h = image.size.height

        var aspectRatio: CGFloat = 1
        var zoomScale: CGFloat = 1
        
        if w > h { // Landscape
            aspectRatio = (h / w)
            view.frame.size.width = screenWidth
            view.frame.size.height = screenWidth * aspectRatio
        } else if h > w { // Portrait
            aspectRatio = w / h
            view.frame.size.width = screenWidth * aspectRatio
            view.frame.size.height = screenWidth
            
            if let minWidth = minWidthForItem {
                let k = minWidth / screenWidth
                zoomScale = (h / w) * k
            }
        } else { // Square
            aspectRatio = 1
            view.frame.size.width = screenWidth
            view.frame.size.height = screenWidth
        }
        
        
        // Centering image view
        view.center = center
        centerAssetView()
        
        // Setting new scale
        minimumZoomScale = zoomScale
        self.zoomScale = zoomScale
    }
    
    func setAssetFrame_fixed(`for` view: UIView, with image: UIImage) {
        guard let landscapeAspectRatio, let portraitAspectRatio else { return }
        
        // Reseting the previous scale
        self.minimumZoomScale = 1
        self.zoomScale = 1
        self.contentInset = .zero
        
        // Calculating and setting the image view frame depending on screenWidth
        let screenWidth = YPImagePickerConfiguration.screenWidth
        
        let w = image.size.width
        let h = image.size.height
        
        if w > h {
            fixedAspectRatio = landscapeAspectRatio
            view.frame.size.width = screenWidth * fixedAspectRatio * (w / h)
            view.frame.size.height = screenWidth * fixedAspectRatio
        } else if h > w {
            fixedAspectRatio = portraitAspectRatio
            view.frame.size.width = screenWidth * (1 / fixedAspectRatio)
            view.frame.size.height = screenWidth * (1 / fixedAspectRatio) * (h / w)
        } else {
            fixedAspectRatio = 1
            view.frame.size.width = screenWidth
            view.frame.size.height = screenWidth
        }
        
        view.center = center
        centerAssetView_fixed()
    }
    
    /// Calculate zoom scale which will fit the image to square
    func calculateSquaredZoomScale() -> CGFloat {
        guard let image = assetImageView.image else {
            ypLog("No image"); return 1.0
        }
        
        if YPConfig.library.fixCropAreaUsingAspectRatio {
            return calculateSquaredZoomScale_fixed(image)
        }
        
        var squareZoomScale: CGFloat = 1.0
        let w = image.size.width
        let h = image.size.height
        
        if w > h { // Landscape
            squareZoomScale = (w / h)
        } else if h > w { // Portrait
            squareZoomScale = (h / w)
        }
        
        return squareZoomScale
    }
    
    func calculateSquaredZoomScale_fixed(_ image: UIImage) -> CGFloat {
        var squareZoomScale: CGFloat = 1.0
        let w = image.size.width
        let h = image.size.height
        
        if w > h { // Landscape
            squareZoomScale = 1 / fixedAspectRatio
        } else if h > w { // Portrait
            squareZoomScale = fixedAspectRatio
        }
        
        return squareZoomScale
    }
    
    // Centring the image frame
    func centerAssetView() {
        let assetView = isVideoMode ? videoView : photoImageView
        let scrollViewBoundsSize = self.bounds.size
        var assetFrame = assetView.frame
        let assetSize = assetView.frame.size
        
        assetFrame.origin.x = (assetSize.width < scrollViewBoundsSize.width) ?
            (scrollViewBoundsSize.width - assetSize.width) / 2.0 : 0
        assetFrame.origin.y = (assetSize.height < scrollViewBoundsSize.height) ?
            (scrollViewBoundsSize.height - assetSize.height) / 2.0 : 0.0
        
        assetView.frame = assetFrame
    }
    
    func centerAssetView_fixed() {
        let assetView = isVideoMode ? videoView : photoImageView
        let scrollViewBoundsSize = self.bounds.size
        var assetFrame = assetView.frame
        let assetSize = assetFrame.size
        
        assetFrame.origin.x = (assetSize.width < scrollViewBoundsSize.width) ?
            (scrollViewBoundsSize.width - assetSize.width) / 2.0 : 0
        assetFrame.origin.y = (assetSize.height < scrollViewBoundsSize.height) ?
            (scrollViewBoundsSize.height - assetSize.height) / 2.0 : 0.0
        assetView.frame = assetFrame
        
        self.contentOffset.x = (assetSize.width > scrollViewBoundsSize.width) ? (assetSize.width - scrollViewBoundsSize.width) / 2.0 : 0
        self.contentOffset.y = (assetSize.height > scrollViewBoundsSize.height) ? (assetSize.height - scrollViewBoundsSize.height) / 2.0 : 0
    }
}

// MARK: UIScrollViewDelegate Protocol
extension YPAssetZoomableView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return isVideoMode ? videoView : photoImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        zoomableViewDelegate?.ypAssetZoomableViewScrollViewDidZoom()
        
        centerAssetView()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        guard let view = view, view == photoImageView || view == videoView else { return }
        
        // prevent to zoom out
        if YPConfig.library.onlySquare && scale < squaredZoomScale {
            self.fitImage(true, animated: true)
        }
        
        zoomableViewDelegate?.ypAssetZoomableViewScrollViewDidEndZooming()
        cropAreaDidChange()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        cropAreaDidChange()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        cropAreaDidChange()
    }
}
