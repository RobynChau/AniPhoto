//
//  EPSCustomAlertProtocol.swift
//  AniPhoto
//
//  Created by PhatCH on 2022/6/29.
//

import UIKit

public enum EPSCustomAlertStyle {
    case alert
    case actionSheet
}

public protocol EPSCustomAlertProtocol: AnyObject {
    /// Should return an instance of ZLCustomAlertProtocol
    static func alert(title: String?, message: String, style: EPSCustomAlertStyle) -> EPSCustomAlertProtocol
    
    func addAction(_ action: EPSCustomAlertAction)
    
    func show(with parentVC: UIViewController?)
}

public class EPSCustomAlertAction: NSObject {
    public enum Style {
        case `default`
        case tint
        case cancel
        case destructive
    }
    
    public let title: String
    
    public let style: EPSCustomAlertAction.Style
    
    public let handler: ((EPSCustomAlertAction) -> Void)?
    
    deinit {
        eps_debugPrint("ZLCustomAlertAction deinit")
    }
    
    public init(title: String, style: EPSCustomAlertAction.Style, handler: ((EPSCustomAlertAction) -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
        super.init()
    }
}

/// internal
extension EPSCustomAlertStyle {
    var toSystemAlertStyle: UIAlertController.Style {
        switch self {
        case .alert:
            return .alert
        case .actionSheet:
            return .actionSheet
        }
    }
}

/// internal
extension EPSCustomAlertAction.Style {
    var toSystemAlertActionStyle: UIAlertAction.Style {
        switch self {
        case .default, .tint:
            return .default
        case .cancel:
            return .cancel
        case .destructive:
            return .destructive
        }
    }
}

/// internal
extension EPSCustomAlertAction {
    func toSystemAlertAction() -> UIAlertAction {
        return UIAlertAction(title: title, style: style.toSystemAlertActionStyle) { _ in
            self.handler?(self)
        }
    }
}
