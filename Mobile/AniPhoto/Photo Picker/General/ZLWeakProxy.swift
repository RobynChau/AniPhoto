//
//  ZLWeakProxy.swift
//  AniPhoto
//
//  Created by PhatCH on 2024/3/6.
//

#if SWIFT_PACKAGE

import UIKit

class ZLWeakProxy: NSObject {
    private weak var target: NSObjectProtocol?
    
    init(target: NSObjectProtocol) {
        self.target = target
        super.init()
    }
    
    class func proxy(target: NSObjectProtocol) -> ZLWeakProxy {
        return ZLWeakProxy(target: target)
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        return target?.responds(to: aSelector) ?? false
    }
}

#endif
