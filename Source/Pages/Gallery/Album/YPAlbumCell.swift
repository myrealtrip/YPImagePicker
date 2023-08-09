//
//  YPAlbumCell.swift
//  YPImagePicker
//
//  Created by Sacha Durand Saint Omer on 20/07/2017.
//  Copyright © 2017 Yummypets. All rights reserved.
//

import UIKit

class YPAlbumCell: UITableViewCell {
    
    let thumbnail = UIImageView()
    let title = UILabel()
    let numberOfItems = UILabel()
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(numberOfItems)
        
        thumbnail.layer.cornerRadius = 8
        thumbnail.clipsToBounds = true
        
        subviews(
            thumbnail,
            stackView
        )
        
        layout(
            6,
            |-12-thumbnail.size(72),
            6
        )
        
        align(horizontally: thumbnail-12-stackView)
        
        thumbnail.contentMode = .scaleAspectFill
        thumbnail.clipsToBounds = true
        thumbnail.backgroundColor = YPConfig.colors.albumCellThumbnailBackgroundColor
        
        title.font = YPConfig.fonts.albumCellTitleFont
        title.textColor = YPConfig.colors.albumCellTitleColor
        numberOfItems.font = YPConfig.fonts.albumCellNumberOfItemsFont
        numberOfItems.textColor = YPConfig.colors.albumCellTitleColor
        backgroundColor = YPConfig.colors.albumBackgroundColor
    }
}
