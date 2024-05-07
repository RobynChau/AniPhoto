//
//  EPSAlbumListController.swift
//  AniPhoto
//
//  Created by PhatCH on 2020/8/18.
//

import UIKit
import Photos

class EPSAlbumListController: UIViewController {
    private lazy var navView = EPSExternalAlbumListNavView(title: localLanguageTextValue(.photo))
    
    private var navBlurView: UIVisualEffectView?
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.backgroundColor = .eps.albumListBgColor
        view.tableFooterView = UIView()
        view.rowHeight = 65
        view.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        view.separatorColor = .eps.separatorLineColor
        view.delegate = self
        view.dataSource = self
        
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .always
        }
        
        EPSAlbumListCell.eps.register(view)
        return view
    }()
    
    private var arrDataSource: [EPSAlbumListModel] = []
    
    private var shouldReloadAlbumList = true
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return EPSPhotoUIConfiguration.default().statusBarStyle
    }
    
    deinit {
        eps_debugPrint("EPSAlbumListController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        PHPhotoLibrary.shared().register(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        
        guard shouldReloadAlbumList else {
            return
        }
        
        DispatchQueue.global().async {
            EPSPhotoManager.getPhotoAlbumList(
                ascending: EPSPhotoUIConfiguration.default().sortAscending,
                allowSelectImage: EPSPhotoConfiguration.default().allowSelectImage,
                allowSelectVideo: EPSPhotoConfiguration.default().allowSelectVideo
            ) { [weak self] albumList in
                self?.arrDataSource.removeAll()
                self?.arrDataSource.append(contentsOf: albumList)
                
                self?.shouldReloadAlbumList = false
                EPSMainAsync {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let navViewNormalH: CGFloat = 44
        
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        var collectionViewInsetTop: CGFloat = 20
        if #available(iOS 11.0, *) {
            insets = view.safeAreaInsets
            collectionViewInsetTop = navViewNormalH
        } else {
            collectionViewInsetTop += navViewNormalH
        }
        
        navView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: insets.top + navViewNormalH)
        
        tableView.frame = CGRect(x: insets.left, y: 0, width: view.frame.width - insets.left - insets.right, height: view.frame.height)
        tableView.contentInset = UIEdgeInsets(top: collectionViewInsetTop, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
    }
    
    private func setupUI() {
        view.backgroundColor = .eps.albumListBgColor
        
        view.addSubview(tableView)
        
        navView.backBtn.isHidden = true
        navView.cancelBlock = { [weak self] in
            let nav = self?.navigationController as? EPSImageNavController
            nav?.cancelBlock?()
            nav?.dismiss(animated: true, completion: nil)
        }
        view.addSubview(navView)
    }
}

extension EPSAlbumListController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EPSAlbumListCell.eps.identifier, for: indexPath) as! EPSAlbumListCell
        
        cell.configureCell(model: arrDataSource[indexPath.row], style: .externalAlbumList)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = EPSThumbnailViewController(albumList: arrDataSource[indexPath.row])
        show(vc, sender: nil)
    }
}

extension EPSAlbumListController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        shouldReloadAlbumList = true
    }
}
