//
//  ZLGeneralDefine.swift
//  AniPhoto
//
//  Created by PhatCH on 2020/8/11.
//

import UIKit
import Photos

let EPSMaxImageWidth: CGFloat = 500

enum EPSLayout {
    static let navTitleFont: UIFont = .eps.font(ofSize: 17)
    
    static let bottomToolViewH: CGFloat = 55
    
    static let bottomToolBtnH: CGFloat = 34
    
    static let bottomToolBtnY: CGFloat = 10
    
    static let bottomToolTitleFont: UIFont = .eps.font(ofSize: 17)
    
    static let bottomToolBtnCornerRadius: CGFloat = 5
}

func markSelected(source: inout [EPSPhotoModel], selected: inout [EPSPhotoModel]) {
    guard !selected.isEmpty else {
        return
    }
    
    var selIds: [String: Bool] = [:]
    var selEditImage: [String: UIImage] = [:]
    var selEditModel: [String: EPSEditImageModel] = [:]
    var selIdAndIndex: [String: Int] = [:]
    
    for (index, m) in selected.enumerated() {
        selIds[m.ident] = true
        selEditImage[m.ident] = m.editImage
        selEditModel[m.ident] = m.editImageModel
        selIdAndIndex[m.ident] = index
    }
    
    source.forEach { m in
        if selIds[m.ident] == true {
            m.isSelected = true
            m.editImage = selEditImage[m.ident]
            m.editImageModel = selEditModel[m.ident]
            selected[selIdAndIndex[m.ident]!] = m
        } else {
            m.isSelected = false
        }
    }
}

func getAppName() -> String {
    if let name = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String {
        return name
    }
    if let name = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
        return name
    }
    if let name = Bundle.main.infoDictionary?["CFBundleName"] as? String {
        return name
    }
    return "App"
}

func deviceIsiPhone() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .phone
}

func deviceIsiPad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}

func deviceSafeAreaInsets() -> UIEdgeInsets {
    var insets: UIEdgeInsets = .zero
    
    if #available(iOS 11, *) {
        insets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
    }
    
    return insets
}

func deviceIsFringeScreen() -> Bool {
    return deviceSafeAreaInsets().top > 0
}

func isSmallScreen() -> Bool {
    return UIScreen.main.bounds.height <= 812
}

func isRTL() -> Bool {
    return UIView.userInterfaceLayoutDirection(for: UIView.appearance().semanticContentAttribute) == .rightToLeft
}

func showAlertView(_ message: String, _ sender: UIViewController?) {
    EPSMainAsync {
        let action = EPSCustomAlertAction(title: localLanguageTextValue(.ok), style: .default, handler: nil)
        showAlertController(title: nil, message: message, style: .alert, actions: [action], sender: sender)
    }
}

func showAlertController(title: String?, message: String?, style: EPSCustomAlertStyle, actions: [EPSCustomAlertAction], sender: UIViewController?) {
    if let alertClass = EPSPhotoUIConfiguration.default().customAlertClass {
        let alert = alertClass.alert(title: title, message: message ?? "", style: style)
        actions.forEach { alert.addAction($0) }
        alert.show(with: sender)
        return
    }
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: style.toSystemAlertStyle)
    actions
        .map { $0.toSystemAlertAction() }
        .forEach { alert.addAction($0) }
    
    let presentedVC = sender ?? UIApplication.shared.keyWindow?.rootViewController
    
    if deviceIsiPad() {
        alert.popoverPresentationController?.sourceView = presentedVC?.view
    }
    
    presentedVC?.eps.showAlertController(alert)
}

func canAddModel(_ model: EPSPhotoModel, currentSelectCount: Int, sender: UIViewController?, showAlert: Bool = true) -> Bool {
    let config = EPSPhotoConfiguration.default()
    
    guard config.canSelectAsset?(model.asset) ?? true else {
        return false
    }
    
    if currentSelectCount >= config.maxSelectCount {
        if showAlert {
            let message = String(format: localLanguageTextValue(.exceededMaxSelectCount), config.maxSelectCount)
            showAlertView(message, sender)
        }
        return false
    }
    
    if currentSelectCount > 0,
       !config.allowMixSelect,
       model.type == .video {
        return false
    }
    
    guard model.type == .video else {
        return true
    }
    
    if model.second > config.maxSelectVideoDuration {
        if showAlert {
            let message = String(format: localLanguageTextValue(.longerThanMaxVideoDuration), config.maxSelectVideoDuration)
            showAlertView(message, sender)
        }
        return false
    }
    
    if model.second < config.minSelectVideoDuration {
        if showAlert {
            let message = String(format: localLanguageTextValue(.shorterThanMinVideoDuration), config.minSelectVideoDuration)
            showAlertView(message, sender)
        }
        return false
    }
    
    guard config.minSelectVideoDataSize > 0 || config.maxSelectVideoDataSize != .greatestFiniteMagnitude,
          let size = model.dataSize else {
        return true
    }
    
    if size > config.maxSelectVideoDataSize {
        if showAlert {
            let value = Int(round(config.maxSelectVideoDataSize / 1024))
            let message = String(format: localLanguageTextValue(.largerThanMaxVideoDataSize), String(value))
            showAlertView(message, sender)
        }
        return false
    }
    
    if size < config.minSelectVideoDataSize {
        if showAlert {
            let value = Int(round(config.minSelectVideoDataSize / 1024))
            let message = String(format: localLanguageTextValue(.smallerThanMinVideoDataSize), String(value))
            showAlertView(message, sender)
        }
        return false
    }
    
    return true
}

func downloadAssetIfNeed(model: EPSPhotoModel, sender: UIViewController?, completion: @escaping (() -> Void)) {
    let config = EPSPhotoConfiguration.default()
    guard model.type == .video,
          model.asset.eps.isInCloud,
          config.downloadVideoBeforeSelecting else {
        completion()
        return
    }

    var requestAssetID: PHImageRequestID?
    let hud = EPSProgressHUD.show(timeout: EPSPhotoUIConfiguration.default().timeout)
    hud.timeoutBlock = { [weak sender] in
        showAlertView(localLanguageTextValue(.timeout), sender)
        if let requestAssetID = requestAssetID {
            PHImageManager.default().cancelImageRequest(requestAssetID)
        }
    }

    requestAssetID = EPSPhotoManager.fetchVideo(for: model.asset, completion: { _, _, isDegraded in
        hud.hide()
        
        if !isDegraded {
            completion()
        }
    })
}

/// Check if the video duration and size meet the requirements
func videoIsMeetRequirements(model: EPSPhotoModel) -> Bool {
    guard model.type == .video else {
        return true
    }
    
    let config = EPSPhotoConfiguration.default()
    
    guard config.minSelectVideoDuration...config.maxSelectVideoDuration ~= model.second else {
        return false
    }
    
    if config.minSelectVideoDataSize > 0 || config.maxSelectVideoDataSize != .greatestFiniteMagnitude,
       let dataSize = model.dataSize,
       !(config.minSelectVideoDataSize...config.maxSelectVideoDataSize ~= dataSize) {
        return false
    }
    
    return true
}

func EPSMainAsync(after: TimeInterval = 0, handler: @escaping (() -> Void)) {
    if after > 0 {
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            handler()
        }
    } else {
        if Thread.isMainThread {
            handler()
        } else {
            DispatchQueue.main.async {
                handler()
            }
        }
    }
}

func eps_debugPrint(_ message: Any...) {
//    message.forEach { debugPrint($0) }
}

func epsLoggerInDebug(_ lastMessage: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {
    #if DEBUG
        print("\(file):\(line): \(lastMessage())")
    #endif
}
