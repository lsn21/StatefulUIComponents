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
    static var figmaShadowSpread = "figmaShadowSpread"
    static var figmaShadowBlur = "figmaShadowBlur"
}

// MARK: - IBInspectable Extension for UIView
public extension UIView {
    
    // MARK: - Figma Shadow Properties (прямой перенос из Figma)
    
    /// Figma: Shadow Color Name (from Assets)
    @IBInspectable var figmaShadowColorName: String? {
        get {
            return objc_getAssociatedObject(self, &UIViewAssociatedKeys.shadowColorName) as? String
        }
        set {
            objc_setAssociatedObject(self, &UIViewAssociatedKeys.shadowColorName, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateFigmaShadow()
        }
    }
    
    /// Figma: Shadow Color (UIColor)
    @IBInspectable var figmaShadowColor: UIColor? {
        get {
            return UIColor(cgColor: layer.shadowColor ?? UIColor.clear.cgColor)
        }
        set {
            objc_setAssociatedObject(self, &UIViewAssociatedKeys.shadowColorName, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateFigmaShadow()
        }
    }
    
    /// Figma: Shadow Opacity (0-100%)
    @IBInspectable var figmaShadowOpacity: Float {
        get {
            return layer.shadowOpacity * 100 // Конвертируем обратно в 0-100
        }
        set {
            objc_setAssociatedObject(self, "figmaShadowOpacity", newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateFigmaShadow()
        }
    }
    
    /// Figma: Shadow X Offset (horizontal)
    @IBInspectable var figmaShadowX: CGFloat {
        get {
            return layer.shadowOffset.width
        }
        set {
            objc_setAssociatedObject(self, "figmaShadowX", newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateFigmaShadow()
        }
    }
    
    /// Figma: Shadow Y Offset (vertical)
    @IBInspectable var figmaShadowY: CGFloat {
        get {
            return layer.shadowOffset.height
        }
        set {
            objc_setAssociatedObject(self, "figmaShadowY", newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateFigmaShadow()
        }
    }
    
    /// Figma: Shadow Blur (прямое значение из Figma)
    @IBInspectable var figmaShadowBlur: CGFloat {
        get {
            return (objc_getAssociatedObject(self, &UIViewAssociatedKeys.figmaShadowBlur) as? CGFloat) ?? layer.shadowRadius * 2
        }
        set {
            objc_setAssociatedObject(self, &UIViewAssociatedKeys.figmaShadowBlur, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateFigmaShadow()
        }
    }
    
    /// Figma: Shadow Spread (специфичный параметр Figma)
    @IBInspectable var figmaShadowSpread: CGFloat {
        get {
            return (objc_getAssociatedObject(self, &UIViewAssociatedKeys.figmaShadowSpread) as? CGFloat) ?? 0
        }
        set {
            objc_setAssociatedObject(self, &UIViewAssociatedKeys.figmaShadowSpread, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateFigmaShadow()
        }
    }
    
    // MARK: - Border Properties (оставляем как было)
    
    @IBInspectable var borderColorName: String? {
        get {
            return objc_getAssociatedObject(self, &UIViewAssociatedKeys.borderColorName) as? String
        }
        set {
            objc_setAssociatedObject(self, &UIViewAssociatedKeys.borderColorName, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateBorderColor()
        }
    }
    
    @IBInspectable var borderUIColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor ?? UIColor.clear.cgColor)
        }
        set {
            layer.borderColor = newValue?.cgColor
            if newValue != nil {
                borderColorName = nil
            }
        }
    }
    
    @IBInspectable var borderWidthIB: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    // MARK: - Corner Radius Properties (оставляем как было)
    
    @IBInspectable var cornerRadiusIB: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            updateFigmaShadow() // Обновляем shadowPath при изменении cornerRadius
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
        // Получаем актуальные значения
        let opacity = (objc_getAssociatedObject(self, "figmaShadowOpacity") as? Float) ?? 0
        let x = (objc_getAssociatedObject(self, "figmaShadowX") as? CGFloat) ?? 0
        let y = (objc_getAssociatedObject(self, "figmaShadowY") as? CGFloat) ?? 0
        let blur = figmaShadowBlur
        let spread = figmaShadowSpread
        
        // Определяем цвет тени
        let shadowColor: UIColor?
        if let colorName = figmaShadowColorName, let color = UIColor(named: colorName) {
            shadowColor = color
        } else {
            shadowColor = figmaShadowColor
        }
        
        guard let color = shadowColor else {
            removeShadow()
            return
        }
        
        // Применяем тень с учетом spread
        applyFigmaShadow(
            color: color,
            opacity: opacity / 100, // Конвертируем 0-100 → 0.0-1.0
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
        layer.shadowRadius = blur / 2 // Figma blur → iOS radius (blur / 2)
        
        // Обрабатываем spread через shadowPath
        if spread == 0 {
            layer.shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            layer.shadowPath = UIBezierPath(rect: rect).cgPath
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
        var mask = layer.maskedCorners
        
        switch corner {
        case .topLeft:
            enabled ? mask.insert(.layerMinXMinYCorner) : mask.remove(.layerMinXMinYCorner)
        case .topRight:
            enabled ? mask.insert(.layerMaxXMinYCorner) : mask.remove(.layerMaxXMinYCorner)
        case .bottomLeft:
            enabled ? mask.insert(.layerMinXMaxYCorner) : mask.remove(.layerMinXMaxYCorner)
        case .bottomRight:
            enabled ? mask.insert(.layerMaxXMaxYCorner) : mask.remove(.layerMaxXMaxYCorner)
        default: break
        }
        
        layer.maskedCorners = mask
        layer.masksToBounds = true
        updateFigmaShadow() // Обновляем тень при изменении углов
    }
    
    // MARK: - Public Methods для Figma Shadows
    
    /// Применить тень из Figma со всеми параметрами
    func applyFigmaShadow(
        color: UIColor,
        opacity: Float, // 0-100%
        x: CGFloat,
        y: CGFloat,
        blur: CGFloat,
        spread: CGFloat
    ) {
        // Сохраняем значения для IB
        objc_setAssociatedObject(self, "figmaShadowOpacity", opacity, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, "figmaShadowX", x, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, "figmaShadowY", y, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &UIViewAssociatedKeys.figmaShadowBlur, blur, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &UIViewAssociatedKeys.figmaShadowSpread, spread, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        applyFigmaShadow(
            color: color,
            opacity: opacity / 100,
            x: x,
            y: y,
            blur: blur,
            spread: spread
        )
    }
    
    /// Удалить тень
    func removeShadow() {
        layer.shadowColor = nil
        layer.shadowOpacity = 0
        layer.shadowRadius = 0
        layer.shadowOffset = .zero
        layer.shadowPath = nil
        
        // Сбрасываем сохраненные значения
        objc_setAssociatedObject(self, "figmaShadowOpacity", Float(0), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &UIViewAssociatedKeys.figmaShadowBlur, CGFloat(0), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &UIViewAssociatedKeys.figmaShadowSpread, CGFloat(0), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// Конвертировать тень из Figma в iOS параметры
    func convertFigmaToiOSShadow(
        x: CGFloat,
        y: CGFloat,
        blur: CGFloat,
        spread: CGFloat,
        opacity: Float
    ) -> (offset: CGSize, radius: CGFloat, opacity: Float, path: CGPath?) {
        let offset = CGSize(width: x, height: y)
        let radius = blur / 2
        let iosOpacity = opacity / 100
        
        var path: CGPath? = nil
        if spread != 0 {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            path = UIBezierPath(rect: rect).cgPath
        }
        
        return (offset, radius, iosOpacity, path)
    }
}

// MARK: - Остальные методы (сохраняем без изменений)

public extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        updateFigmaShadow()
    }
    
    func applyShadow(color: UIColor, opacity: Float, radius: CGFloat, offset: CGSize) {
        applyFigmaShadow(color: color, opacity: opacity * 100, x: offset.width, y: offset.height, blur: radius * 2, spread: 0)
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

// MARK: - Utility Extensions
extension UIColor {
    var hexString: String {
        guard let components = cgColor.components, components.count >= 3 else {
            return "#000000"
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}

public func setupUIExtensions() {
    UIView.swizzleViewMethods()
}
