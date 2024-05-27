//
//  EPSBaseStickerView.swift
//  AniPhoto
//
//  Created by PhatCH on 2022/11/28.
//

import UIKit

protocol EPSStickerViewDelegate: NSObject {
    /// Called when scale or rotate or move.
    func stickerBeginOperation(_ sticker: EPSBaseStickerView)
    
    /// Called during scale or rotate or move.
    func stickerOnOperation(_ sticker: EPSBaseStickerView, panGes: UIPanGestureRecognizer)
    
    /// Called after scale or rotate or move.
    func stickerEndOperation(_ sticker: EPSBaseStickerView, panGes: UIPanGestureRecognizer)
    
    /// Called when tap sticker.
    func stickerDidTap(_ sticker: EPSBaseStickerView)
    
    func sticker(_ textSticker: EPSTextStickerView, editText text: String)
}

protocol EPSStickerViewAdditional: NSObject {
    var isGestureEnabled: Bool { get set }
    
    func resetState()
    
    func moveToTrashCan()
    
    func addScale(_ scale: CGFloat)
}

class EPSBaseStickerView: UIView, UIGestureRecognizerDelegate {
    private enum Direction: Int {
        case up = 0
        case right = 90
        case bottom = 180
        case left = 270
    }
    
    var id: String
    
    var borderWidth = 1 / UIScreen.main.scale
    
    var firstLayout = true
    
    let originScale: CGFloat
    
    let originAngle: CGFloat
    
    var maxGesScale: CGFloat
    
    var originTransform: CGAffineTransform = .identity
    
    var timer: Timer?
    
    var totalTranslationPoint: CGPoint = .zero
    
    var gesTranslationPoint: CGPoint = .zero
    
    var gesRotation: CGFloat = 0
    
    var gesScale: CGFloat = 1
    
    var onOperation = false
    
    var isGestureEnabled = true
    
    var originFrame: CGRect
    
    lazy var tapGes = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
    
    lazy var pinchGes: UIPinchGestureRecognizer = {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(_:)))
        pinch.delegate = self
        return pinch
    }()
    
    lazy var panGes: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        pan.delegate = self
        return pan
    }()
    
    var state: EPSBaseStickerState {
        fatalError()
    }
    
    var borderView: UIView {
        return self
    }
    
    weak var delegate: EPSStickerViewDelegate?
    
    deinit {
        cleanTimer()
    }
    
    class func initWithState(_ state: EPSBaseStickerState) -> EPSBaseStickerView? {
        if let state = state as? ZLTextStickerState {
            return EPSTextStickerView(state: state)
        } else if let state = state as? ZLImageStickerState {
            return EPSImageStickerView(state: state)
        } else {
            return nil
        }
    }
    
    init(
        id: String = UUID().uuidString,
        originScale: CGFloat,
        originAngle: CGFloat,
        originFrame: CGRect,
        gesScale: CGFloat = 1,
        gesRotation: CGFloat = 0,
        totalTranslationPoint: CGPoint = .zero,
        showBorder: Bool = true
    ) {
        self.id = id
        self.originScale = originScale
        self.originAngle = originAngle
        self.originFrame = originFrame
        maxGesScale = 4 / originScale
        super.init(frame: .zero)
        
        self.gesScale = gesScale
        self.gesRotation = gesRotation
        self.totalTranslationPoint = totalTranslationPoint
        
        borderView.layer.borderWidth = borderWidth
        hideBorder()
        if showBorder {
            startTimer()
        }
        
        addGestureRecognizer(tapGes)
        addGestureRecognizer(pinchGes)
        
        let rotationGes = UIRotationGestureRecognizer(target: self, action: #selector(rotationAction(_:)))
        rotationGes.delegate = self
        addGestureRecognizer(rotationGes)
        
        addGestureRecognizer(panGes)
        tapGes.require(toFail: panGes)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard firstLayout else {
            return
        }
        
        // Rotate must be first when first layout.
        transform = transform.rotated(by: originAngle.eps.toPi)
        
        if totalTranslationPoint != .zero {
            let direction = direction(for: originAngle)
            if direction == .right {
                transform = transform.translatedBy(x: totalTranslationPoint.y, y: -totalTranslationPoint.x)
            } else if direction == .bottom {
                transform = transform.translatedBy(x: -totalTranslationPoint.x, y: -totalTranslationPoint.y)
            } else if direction == .left {
                transform = transform.translatedBy(x: -totalTranslationPoint.y, y: totalTranslationPoint.x)
            } else {
                transform = transform.translatedBy(x: totalTranslationPoint.x, y: totalTranslationPoint.y)
            }
        }
        
        transform = transform.scaledBy(x: originScale, y: originScale)
        
        originTransform = transform
        
        if gesScale != 1 {
            transform = transform.scaledBy(x: gesScale, y: gesScale)
        }
        if gesRotation != 0 {
            transform = transform.rotated(by: gesRotation)
        }
        
        firstLayout = false
        setupUIFrameWhenFirstLayout()
    }
    
    func setupUIFrameWhenFirstLayout() {}
    
    private func direction(for angle: CGFloat) -> EPSBaseStickerView.Direction {
        // 将角度转换为0~360，并对360取余
        let angle = ((Int(angle) % 360) + 360) % 360
        return EPSBaseStickerView.Direction(rawValue: angle) ?? .up
    }
    
    @objc func tapAction(_ ges: UITapGestureRecognizer) {
        guard isGestureEnabled else { return }
        
        superview?.bringSubviewToFront(self)
        delegate?.stickerDidTap(self)
        startTimer()
    }
    
    @objc func pinchAction(_ ges: UIPinchGestureRecognizer) {
        guard isGestureEnabled else { return }
        
        let scale = min(maxGesScale, gesScale * ges.scale)
        ges.scale = 1
        
        var scaleChanged = false
        if scale != gesScale {
            gesScale = scale
            scaleChanged = true
        }
        
        if ges.state == .began {
            setOperation(true)
        } else if ges.state == .changed {
            if scaleChanged {
                updateTransform()
            }
        } else if ges.state == .ended || ges.state == .cancelled {
            // 当有拖动时，在panAction中执行setOperation(false)
            if gesTranslationPoint == .zero {
                setOperation(false)
            }
        }
    }
    
    @objc func rotationAction(_ ges: UIRotationGestureRecognizer) {
        guard isGestureEnabled else { return }
        
        gesRotation += ges.rotation
        ges.rotation = 0
        
        if ges.state == .began {
            setOperation(true)
        } else if ges.state == .changed {
            updateTransform()
        } else if ges.state == .ended || ges.state == .cancelled {
            if gesTranslationPoint == .zero {
                setOperation(false)
            }
        }
    }
    
    @objc func panAction(_ ges: UIPanGestureRecognizer) {
        guard isGestureEnabled else { return }
        
        let point = ges.translation(in: superview)
        gesTranslationPoint = CGPoint(x: point.x / originScale, y: point.y / originScale)
        
        if ges.state == .began {
            setOperation(true)
        } else if ges.state == .changed {
            updateTransform()
        } else if ges.state == .ended || ges.state == .cancelled {
            totalTranslationPoint.x += point.x
            totalTranslationPoint.y += point.y
            setOperation(false)
            let direction = direction(for: originAngle)
            if direction == .right {
                originTransform = originTransform.translatedBy(x: gesTranslationPoint.y, y: -gesTranslationPoint.x)
            } else if direction == .bottom {
                originTransform = originTransform.translatedBy(x: -gesTranslationPoint.x, y: -gesTranslationPoint.y)
            } else if direction == .left {
                originTransform = originTransform.translatedBy(x: -gesTranslationPoint.y, y: gesTranslationPoint.x)
            } else {
                originTransform = originTransform.translatedBy(x: gesTranslationPoint.x, y: gesTranslationPoint.y)
            }
            gesTranslationPoint = .zero
        }
    }
    
    func setOperation(_ isOn: Bool) {
        if isOn, !onOperation {
            onOperation = true
            cleanTimer()
            borderView.layer.borderColor = UIColor.white.cgColor
            superview?.bringSubviewToFront(self)
            delegate?.stickerBeginOperation(self)
        } else if !isOn, onOperation {
            onOperation = false
            startTimer()
            delegate?.stickerEndOperation(self, panGes: panGes)
        }
    }
    
    func updateTransform() {
        var transform = originTransform
        
        let direction = direction(for: originAngle)
        if direction == .right {
            transform = transform.translatedBy(x: gesTranslationPoint.y, y: -gesTranslationPoint.x)
        } else if direction == .bottom {
            transform = transform.translatedBy(x: -gesTranslationPoint.x, y: -gesTranslationPoint.y)
        } else if direction == .left {
            transform = transform.translatedBy(x: -gesTranslationPoint.y, y: gesTranslationPoint.x)
        } else {
            transform = transform.translatedBy(x: gesTranslationPoint.x, y: gesTranslationPoint.y)
        }
        // Scale must after translate.
        transform = transform.scaledBy(x: gesScale, y: gesScale)
        // Rotate must after scale.
        transform = transform.rotated(by: gesRotation)
        self.transform = transform
        
        delegate?.stickerOnOperation(self, panGes: panGes)
    }
    
    @objc private func hideBorder() {
        borderView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func startTimer() {
        cleanTimer()
        borderView.layer.borderColor = UIColor.white.cgColor
        timer = Timer.scheduledTimer(timeInterval: 2, target: EPSWeakProxy(target: self), selector: #selector(hideBorder), userInfo: nil, repeats: false)
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func cleanTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension EPSBaseStickerView: EPSStickerViewAdditional {
    func resetState() {
        onOperation = false
        cleanTimer()
        hideBorder()
    }
    
    func moveToTrashCan() {
        cleanTimer()
        removeFromSuperview()
    }
    
    func addScale(_ scale: CGFloat) {
        // Revert zoom scale.
        transform = transform.scaledBy(x: 1 / originScale, y: 1 / originScale)
        // Revert ges scale.
        transform = transform.scaledBy(x: 1 / gesScale, y: 1 / gesScale)
        // Revert ges rotation.
        transform = transform.rotated(by: -gesRotation)
        
        var origin = frame.origin
        origin.x *= scale
        origin.y *= scale
        
        let newSize = CGSize(width: frame.width * scale, height: frame.height * scale)
        let newOrigin = CGPoint(x: frame.minX + (frame.width - newSize.width) / 2, y: frame.minY + (frame.height - newSize.height) / 2)
        let diffX: CGFloat = (origin.x - newOrigin.x)
        let diffY: CGFloat = (origin.y - newOrigin.y)
        
        let direction = direction(for: originAngle)
        if direction == .right {
            transform = transform.translatedBy(x: diffY, y: -diffX)
            originTransform = originTransform.translatedBy(x: diffY / originScale, y: -diffX / originScale)
        } else if direction == .bottom {
            transform = transform.translatedBy(x: -diffX, y: -diffY)
            originTransform = originTransform.translatedBy(x: -diffX / originScale, y: -diffY / originScale)
        } else if direction == .left {
            transform = transform.translatedBy(x: -diffY, y: diffX)
            originTransform = originTransform.translatedBy(x: -diffY / originScale, y: diffX / originScale)
        } else {
            transform = transform.translatedBy(x: diffX, y: diffY)
            originTransform = originTransform.translatedBy(x: diffX / originScale, y: diffY / originScale)
        }
        totalTranslationPoint.x += diffX
        totalTranslationPoint.y += diffY
        
        transform = transform.scaledBy(x: scale, y: scale)
        
        // Readd zoom scale.
        transform = transform.scaledBy(x: originScale, y: originScale)
        // Readd ges scale.
        transform = transform.scaledBy(x: gesScale, y: gesScale)
        // Readd ges rotation.
        transform = transform.rotated(by: gesRotation)
        
        gesScale *= scale
        maxGesScale *= scale
    }
}
