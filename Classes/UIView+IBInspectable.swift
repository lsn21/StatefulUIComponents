//
//  UIView+IBInspectable.swift
//  StatefulUIComponents
//
//  Created by Siarhei Lukyanau on 23.12.25.
//

import UIKit

// MARK: - Associated Keys for UIView
private struct UIViewAssociatedKeys {
    static var borderColorName = "borderColorName"
    static var shadowColorName = "shadowColorName"
    static var shadowSpread = "shadowSpread"
    static var shadowBlur = "shadowBlur"
    static var shadowOpacity = "shadowOpacity"
    static var shadowX = "shadowX"
    static var shadowY = "shadowY"
}

// MARK: - IBInspectable Extension for UIView
public extension UIView {
    
    // MARK: - Figma Shadow Properties (сокращенные названия для IB)
    
    /// Shadow Color Name (from Assets) - короткое название
    @IBInspectable var fsColorName: String? {
        get {
            return objc_getAssociatedObject(self, &UIViewAssociatedKeys.shadowColorName) as? String
        }
        set {
            objc_setAssociatedObject(self, &UIViewAssociatedKeys.shadowColorName, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateFigmaShadow()
        }
    }
    
    /// Shadow Color (UIColor) - короткое название
    @IBInspectable var fsColor: UIColor? {
        get {
            guard let shadowColor = layer.shadowColor else { return nil }
            return UIColor(cgColor: shadowColor)
        }
        set {
            // Очищаем имя цвета при установке UIColor
            objc_setAssociatedObject(self, &UIViewAssociatedKeys.shadowColorName, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateFigmaShadow()
        }
    }
    
    /// Shadow Opacity (0-100%) - короткое название
    @IBInspectable var fsOpacity: Float {
        get {
            return (objc_getAssociatedObject(self, &UIViewAssociatedKeys.shadowOpacity) as? Float) ?? (layer.shadowOpacity * 100)
        }
        set {
            objc_setAssociatedObject(self, &UIViewAssociatedKeys.shadowOpacity, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateFigmaShadow()
        }
    }
    
    /// Shadow X Offset (horizontal) - короткое название
    @IBInspectable var fsX: CGFloat {
        get {
            return (objc_getAssociatedObject(self, &UIViewAssociatedKeys.shadowX) as? CGFloat) ?? layer.shadowOffset.width
        }
        set {
            objc_setAssociatedObject(self, &UIViewAssociatedKeys.shadowX, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateFigmaShadow()
        }
    }
    
    /// Shadow Y Offset (vertical) - короткое название
    @IBInspectable var fsY: CGFloat {
        get {
            return (objc_getAssociatedObject(self, &UIViewAssociatedKeys.shadowY) as? CGFloat) ?? layer.shadowOffset.height
        }
        set {
            objc_setAssociatedObject(self, &UIViewAssociatedKeys.shadowY, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateFigmaShadow()
        }
    }
    
    /// Shadow Blur - короткое название
    @IBInspectable var fsBlur: CGFloat {
        get {
            return (objc_getAssociatedObject(self, &UIViewAssociatedKeys.shadowBlur) as? CGFloat) ?? (layer.shadowRadius * 2)
        }
        set {
            objc_setAssociatedObject(self, &UIViewAssociatedKeys.shadowBlur, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateFigmaShadow()
        }
    }
    
    /// Shadow Spread - короткое название
    @IBInspectable var fsSpread: CGFloat {
        get {
            return (objc_getAssociatedObject(self, &UIViewAssociatedKeys.shadowSpread) as? CGFloat) ?? 0
        }
        set {
            objc_setAssociatedObject(self, &UIViewAssociatedKeys.shadowSpread, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateFigmaShadow()
        }
    }
    
    // MARK: - Border Properties (короткие названия)
    
    @IBInspectable var borderColorName: String? {
        get {
            return objc_getAssociatedObject(self, &UIViewAssociatedKeys.borderColorName) as? String
        }
        set {
            objc_setAssociatedObject(self, &UIViewAssociatedKeys.borderColorName, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateBorderColor()
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let borderColor = layer.borderColor else { return nil }
            return UIColor(cgColor: borderColor)
        }
        set {
            layer.borderColor = newValue?.cgColor
            if newValue != nil {
                borderColorName = nil
            }
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    // MARK: - Corner Radius Properties (короткие названия)
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            updateFigmaShadow()
        }
    }
    
    @IBInspectable var topLeftCorner: Bool {
        get { return getCornerState(for: .topLeft) }
        set { setCornerState(newValue, for: .topLeft) }
    }
    
    @IBInspectable var topRightCorner: Bool {
        get { return getCornerState(for: .topRight) }
        set { setCornerState(newValue, for: .topRight) }
    }
    
    @IBInspectable var bottomLeftCorner: Bool {
        get { return getCornerState(for: .bottomLeft) }
        set { setCornerState(newValue, for: .bottomLeft) }
    }
    
    @IBInspectable var bottomRightCorner: Bool {
        get { return getCornerState(for: .bottomRight) }
        set { setCornerState(newValue, for: .bottomRight) }
    }
    
    // MARK: - Private Methods
    
    private func updateFigmaShadow() {
        // Получаем актуальные значения из associated objects
        let opacity = fsOpacity
        let x = fsX
        let y = fsY
        let blur = fsBlur
        let spread = fsSpread
        
        // Определяем цвет тени
        let shadowColor: UIColor?
        if let colorName = fsColorName, let color = UIColor(named: colorName) {
            shadowColor = color
        } else {
            shadowColor = fsColor
        }
        
        guard let color = shadowColor else {
            removeShadow()
            return
        }
        
        // Применяем тень с учетом spread
        applyFigmaShadow(
            color: color,
            opacity: opacity / 400,
            x: x,
            y: y,
            blur: blur,
            spread: spread
        )
    }
    
    private func applyFigmaShadow(color: UIColor, opacity: Float, x: CGFloat, y: CGFloat, blur: CGFloat, spread: CGFloat) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize(width: x, height: y)
        layer.shadowRadius = blur / 2
        
        // Обрабатываем spread через shadowPath с учетом cornerRadius
        if spread == 0 {
            layer.shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            
            // Используем cornerRadius слоя для создания скругленного пути
            let cornerRadius = layer.cornerRadius
            layer.shadowPath = UIBezierPath(
                roundedRect: rect,
                cornerRadius: cornerRadius
            ).cgPath
        }
        
        layer.masksToBounds = false
    }

    private func updateBorderColor() {
        guard let colorName = borderColorName, let color = UIColor(named: colorName) else { return }
        layer.borderColor = color.cgColor
    }
    
    private func getCornerState(for corner: UIRectCorner) -> Bool {
        let mask = layer.maskedCorners
        switch corner {
        case .topLeft: return mask.contains(.layerMinXMinYCorner)
        case .topRight: return mask.contains(.layerMaxXMinYCorner)
        case .bottomLeft: return mask.contains(.layerMinXMaxYCorner)
        case .bottomRight: return mask.contains(.layerMaxXMaxYCorner)
        default: return false
        }
    }
    
    private func setCornerState(_ enabled: Bool, for corner: UIRectCorner) {
        var corners = layer.maskedCorners
        
        switch corner {
        case .topLeft:
            if enabled {
                corners.insert(.layerMinXMinYCorner)
            } else {
                corners.remove(.layerMinXMinYCorner)
            }
        case .topRight:
            if enabled {
                corners.insert(.layerMaxXMinYCorner)
            } else {
                corners.remove(.layerMaxXMinYCorner)
            }
        case .bottomLeft:
            if enabled {
                corners.insert(.layerMinXMaxYCorner)
            } else {
                corners.remove(.layerMinXMaxYCorner)
            }
        case .bottomRight:
            if enabled {
                corners.insert(.layerMaxXMaxYCorner)
            } else {
                corners.remove(.layerMaxXMaxYCorner)
            }
        default: break
        }
        
        layer.maskedCorners = corners
        layer.masksToBounds = true
        updateFigmaShadow()
    }
    
    // MARK: - Public Methods для Figma Shadows
    
    /// Применить тень из Figma со всеми параметрами
    func applyFigmaStyleShadow(
        color: UIColor,
        opacity: Float, // 0-100%
        x: CGFloat,
        y: CGFloat,
        blur: CGFloat,
        spread: CGFloat
    ) {
        // Сохраняем значения для IB
        fsColor = color
        fsOpacity = opacity
        fsX = x
        fsY = y
        fsBlur = blur
        fsSpread = spread
        
        updateFigmaShadow()
    }
    
    /// Удалить тень
    func removeShadow() {
        layer.shadowColor = nil
        layer.shadowOpacity = 0
        layer.shadowRadius = 0
        layer.shadowOffset = .zero
        layer.shadowPath = nil
        
        // Сбрасываем сохраненные значения
        fsOpacity = 0
        fsBlur = 0
        fsSpread = 0
        fsX = 0
        fsY = 0
        fsColor = nil
        fsColorName = nil
    }
}

// MARK: - Остальные методы

public extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        updateFigmaShadow()
    }
    
    func applyShadow(color: UIColor, opacity: Float, radius: CGFloat, offset: CGSize) {
        applyFigmaStyleShadow(color: color, opacity: opacity * 100, x: offset.width, y: offset.height, blur: radius * 2, spread: 0)
    }
    
    func addBorder(color: UIColor, width: CGFloat) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
    func removeBorder() {
        layer.borderColor = nil
        layer.borderWidth = 0
    }
    
    func applyGradient(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0.5, y: 0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func removeGradient() {
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
    }
    
    // MARK: - Animation Methods
    func pulseAnimation(duration: TimeInterval = 0.5) {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = duration
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 1
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        layer.add(pulse, forKey: "pulse")
    }
    
    func shakeAnimation() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-20, 20, -20, 20, -10, 10, -5, 5, 0]
        layer.add(animation, forKey: "shake")
    }
}

// MARK: - Lifecycle Methods
extension UIView {
    internal func viewAwakeFromNib() {
        updateBorderColor()
        updateFigmaShadow()
    }
    
    internal func viewPrepareForInterfaceBuilder() {
        updateBorderColor()
        updateFigmaShadow()
    }
}

// MARK: - Method Swizzling
extension UIView {
    static func swizzleViewMethods() {
        let originalAwake = class_getInstanceMethod(UIView.self, #selector(awakeFromNib))
        let swizzledAwake = class_getInstanceMethod(UIView.self, #selector(swizzled_viewAwakeFromNib))
        
        if let original = originalAwake, let swizzled = swizzledAwake {
            method_exchangeImplementations(original, swizzled)
        }
        
        let originalPrepare = class_getInstanceMethod(UIView.self, #selector(prepareForInterfaceBuilder))
        let swizzledPrepare = class_getInstanceMethod(UIView.self, #selector(swizzled_viewPrepareForInterfaceBuilder))
        
        if let original = originalPrepare, let swizzled = swizzledPrepare {
            method_exchangeImplementations(original, swizzled)
        }
    }
    
    @objc private func swizzled_viewAwakeFromNib() {
        swizzled_viewAwakeFromNib()
        viewAwakeFromNib()
    }
    
    @objc private func swizzled_viewPrepareForInterfaceBuilder() {
        swizzled_viewPrepareForInterfaceBuilder()
        viewPrepareForInterfaceBuilder()
    }
}

// MARK: - Convenience Initializers
public extension UIView {
    convenience init(backgroundColor: UIColor) {
        self.init(frame: .zero)
        self.backgroundColor = backgroundColor
    }
    
    convenience init(cornerRadius: CGFloat) {
        self.init(frame: .zero)
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
}

public func setupUIExtensions() {
    UIView.swizzleViewMethods()
}
