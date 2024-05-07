//
//  EPSEditorManager.swift
//  AniPhoto
//
//  Created by PhatCH on 2023/9/25.
//

import Foundation

public enum EPSEditorAction {
    case draw(EPSDrawPath)
    case eraser([EPSDrawPath])
    case clip(oldStatus: EPSClipStatus, newStatus: EPSClipStatus)
    case sticker(oldState: EPSBaseStickerState?, newState: EPSBaseStickerState?)
    case mosaic(EPSMosaicPath)
    case filter(oldFilter: EPSFilter?, newFilter: EPSFilter?)
    case adjust(oldStatus: EPSAdjustStatus, newStatus: EPSAdjustStatus)
}

protocol EPSEditorManagerDelegate: AnyObject {
    func editorManager(_ manager: EPSEditorManager, didUpdateActions actions: [EPSEditorAction], redoActions: [EPSEditorAction])
    
    func editorManager(_ manager: EPSEditorManager, undoAction action: EPSEditorAction)
    
    func editorManager(_ manager: EPSEditorManager, redoAction action: EPSEditorAction)
}

class EPSEditorManager {
    private(set) var actions: [EPSEditorAction] = []
    private(set) var redoActions: [EPSEditorAction] = []
    
    weak var delegate: EPSEditorManagerDelegate?
    
    init(actions: [EPSEditorAction] = []) {
        self.actions = actions
        redoActions = actions
    }
    
    func storeAction(_ action: EPSEditorAction) {
        actions.append(action)
        redoActions = actions
        
        deliverUpdate()
    }
    
    func undoAction() {
        guard let preAction = actions.popLast() else { return }
        
        delegate?.editorManager(self, undoAction: preAction)
        deliverUpdate()
    }
    
    func redoAction() {
        guard actions.count < redoActions.count else { return }
        
        let action = redoActions[actions.count]
        actions.append(action)
        
        delegate?.editorManager(self, redoAction: action)
        deliverUpdate()
    }
    
    private func deliverUpdate() {
        delegate?.editorManager(self, didUpdateActions: actions, redoActions: redoActions)
    }
}
