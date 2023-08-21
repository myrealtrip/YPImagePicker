//
//  YPAlbumVC.swift
//  YPImagePicker
//
//  Created by Sacha Durand Saint Omer on 20/07/2017.
//  Copyright © 2017 Yummypets. All rights reserved.
//

import UIKit
import Photos

public class YPAlbumVC: UIViewController {
    
    public override var prefersStatusBarHidden: Bool {
         return YPConfig.hidesStatusBar
    }
    
    var didSelectAlbum: ((YPAlbum) -> Void)?
    var albums = [YPAlbum]()
    let albumsManager: YPAlbumsManager
    
    let v = YPAlbumView()
    public override func loadView() { view = v }
    
    required init(albumsManager: YPAlbumsManager) {
        self.albumsManager = albumsManager
        super.init(nibName: nil, bundle: nil)
        title = YPConfig.wordings.albumsTitle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [.font: YPConfig.fonts.navigationBarTitleFont,
                                                                   .foregroundColor: YPConfig.colors.albumTitleColor]
        let image = imageFromBundle("ico_close").withTintColor(.white)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(close))
        navigationController?.navigationBar.barTintColor = YPConfig.colors.albumBarTintColor
        navigationController?.navigationBar.tintColor = YPConfig.colors.albumTintColor
        setUpTableView()
        fetchAlbumsInBackground()
    }
    
    func fetchAlbumsInBackground() {
        v.spinner.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.albums = self?.albumsManager.fetchAlbums() ?? []
            DispatchQueue.main.async {
                self?.v.spinner.stopAnimating()
                self?.v.tableView.isHidden = false
                self?.v.tableView.reloadData()
            }
        }
    }
    
    @objc
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    func setUpTableView() {
        v.tableView.isHidden = true
        v.tableView.dataSource = self
        v.tableView.delegate = self
        v.tableView.rowHeight = UITableView.automaticDimension
        v.tableView.estimatedRowHeight = 84
        v.tableView.separatorStyle = .none
        v.tableView.register(YPAlbumCell.self, forCellReuseIdentifier: "AlbumCell")
    }
}

extension YPAlbumVC: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let album = albums[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as? YPAlbumCell {
            cell.thumbnail.backgroundColor = .ypSystemGray
            cell.thumbnail.image = album.thumbnail
            cell.title.text = album.title
            cell.numberOfItems.text = "\(album.numberOfItems)"
            return cell
        }
        return UITableViewCell()
    }
}

extension YPAlbumVC: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectAlbum?(albums[indexPath.row])
    }
}
