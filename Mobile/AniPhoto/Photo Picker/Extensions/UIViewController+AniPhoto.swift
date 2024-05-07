//
//  UIViewController+AniPhoto.swift
//  AniPhoto
//
//  Created by PhatCH on 2021/12/28.
//

import UIKit

extension AniPhotoWrapper where Base: UIViewController {
    func showAlertController(_ alertController: UIAlertController) {
        if deviceIsiPad() {
            alertController.popoverPresentationController?.sourceView = base.view
        }
        base.showDetailViewController(alertController, sender: nil)
    }
}
