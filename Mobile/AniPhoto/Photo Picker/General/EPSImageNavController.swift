//
//  EPSImageNavController.swift
//  AniPhoto
//
//  Created by PhatCH on 2020/8/18.
//


import UIKit
import Photos

class EPSImageNavController: UINavigationController {
    var isSelectedOriginal = false
    
    var arrSelectedModels: [EPSPhotoModel] = []
    
    var selectImageBlock: (() -> Void)?
    
    var cancelBlock: (() -> Void)?
    
    deinit {
        eps_debugPrint("EPSImageNavController deinit")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return EPSPhotoUIConfiguration.default().statusBarStyle
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        navigationBar.barStyle = .black
        navigationBar.isTranslucent = true
        modalPresentationStyle = .fullScreen
        isNavigationBarHidden = true
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
