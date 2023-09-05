//
//  YPAlbum.swift
//  YPImagePicker
//
//  Created by Sacha Durand Saint Omer on 20/07/2017.
//  Copyright © 2017 Yummypets. All rights reserved.
//

import UIKit
import Photos

public struct YPAlbum {
    public var title: String = ""
    var thumbnail: UIImage?
    var numberOfItems: Int = 0
    var collection: PHAssetCollection?
}
