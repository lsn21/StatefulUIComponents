//
//  WebKit+IBInspectable.swift
//
//  Created by Siarhei Lukyanau on 31.12.25.
//

import WebKit

// MARK: - Associated Keys for WKWebView
private struct WKWebViewAssociatedKeys {
    static var borderColorName = "borderColorName"
    static var shadowColorName = "shadowColorName"
    static var backgroundColorName = "backgroundColorName"
}

// MARK: - IBInspectable Extension for WKWebView
public extension WKWebView {
    
    // MARK: - Border Properties
    
    /// Name of the border color from assets
    @IBInspectable var borderColorName: String? {
        get {
            return objc_getAssociatedObject(self, &WKWebViewAssociatedKeys.borderColorName) as? String
        }
        set {
            objc_setAssociatedObject(self, &WKWebViewAssociatedKeys.borderColorName, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateBorderColor()
        }
    }
    
    /// Border color through UIColor
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
    
    /// Border width
    @IBInspectable var borderWidthIB: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    // MARK: - Corner Radius Properties
    
    /// Corner radius for all corners
    @IBInspectable var cornerRadiusIB: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            if newValue > 0 {
                layer.masksToBounds = true
            }
        }
    }
    
    /// Enable/disable top-left corner rounding
    @IBInspectable var topLeftCorner: Bool {
        get {
            return getCornerState(for: .topLeft)
        }
        set {
            setCornerState(newValue, for: .topLeft)
        }
    }
    
    /// Enable/disable top-right corner rounding
    @IBInspectable var topRightCorner: Bool {
        get {
            return getCornerState(for: .topRight)
        }
        set {
            setCornerState(newValue, for: .topRight)
        }
    }
    
    /// Enable/disable bottom-left corner rounding
    @IBInspectable var bottomLeftCorner: Bool {
        get {
            return getCornerState(for: .bottomLeft)
        }
        set {
            setCornerState(newValue, for: .bottomLeft)
        }
    }
    
    /// Enable/disable bottom-right corner rounding
    @IBInspectable var bottomRightCorner: Bool {
        get {
            return getCornerState(for: .bottomRight)
        }
        set {
            setCornerState(newValue, for: .bottomRight)
        }
    }
    
    // MARK: - Shadow Properties
    
    /// Name of the shadow color from assets
    @IBInspectable var shadowColorName: String? {
        get {
            return objc_getAssociatedObject(self, &WKWebViewAssociatedKeys.shadowColorName) as? String
        }
        set {
            objc_setAssociatedObject(self, &WKWebViewAssociatedKeys.shadowColorName, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateShadowColor()
        }
    }
    
    /// Shadow color through UIColor
    @IBInspectable var shadowUIColor: UIColor? {
        get {
            return UIColor(cgColor: layer.shadowColor ?? UIColor.clear.cgColor)
        }
        set {
            layer.shadowColor = newValue?.cgColor
            if newValue != nil {
                shadowColorName = nil
            }
        }
    }
    
    /// Shadow offset
    @IBInspectable var shadowOffsetIB: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    /// Shadow opacity
    @IBInspectable var shadowOpacityIB: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    /// Shadow radius
    @IBInspectable var shadowRadiusIB: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    // MARK: - Background Color Properties
    
    /// Background color name from assets
    @IBInspectable var backgroundColorName: String? {
        get {
            return objc_getAssociatedObject(self, &WKWebViewAssociatedKeys.backgroundColorName) as? String
        }
        set {
            objc_setAssociatedObject(self, &WKWebViewAssociatedKeys.backgroundColorName, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateBackgroundColor()
        }
    }
    
    /// Background color through UIColor
    @IBInspectable var backgroundUIColor: UIColor? {
        get {
            return self.backgroundColor
        }
        set {
            self.backgroundColor = newValue
            if newValue != nil {
                backgroundColorName = nil
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func updateBorderColor() {
        guard let colorName = borderColorName, let color = UIColor(named: colorName) else {
            return
        }
        layer.borderColor = color.cgColor
    }
    
    private func updateShadowColor() {
        guard let colorName = shadowColorName, let color = UIColor(named: colorName) else {
            return
        }
        layer.shadowColor = color.cgColor
    }
    
    private func updateBackgroundColor() {
        guard let colorName = backgroundColorName, let color = UIColor(named: colorName) else {
            return
        }
        self.backgroundColor = color
    }
    
    private func getCornerState(for corner: UIRectCorner) -> Bool {
        let mask = layer.maskedCorners
        switch corner {
        case .topLeft:
            return mask.contains(.layerMinXMinYCorner)
        case .topRight:
            return mask.contains(.layerMaxXMinYCorner)
        case .bottomLeft:
            return mask.contains(.layerMinXMaxYCorner)
        case .bottomRight:
            return mask.contains(.layerMaxXMaxYCorner)
        default:
            return false
        }
    }
    
    private func setCornerState(_ enabled: Bool, for corner: UIRectCorner) {
        var mask = layer.maskedCorners
        
        switch corner {
        case .topLeft:
            if enabled {
                mask.insert(.layerMinXMinYCorner)
            } else {
                mask.remove(.layerMinXMinYCorner)
            }
        case .topRight:
            if enabled {
                mask.insert(.layerMaxXMinYCorner)
            } else {
                mask.remove(.layerMaxXMinYCorner)
            }
        case .bottomLeft:
            if enabled {
                mask.insert(.layerMinXMaxYCorner)
            } else {
                mask.remove(.layerMinXMaxYCorner)
            }
        case .bottomRight:
            if enabled {
                mask.insert(.layerMaxXMaxYCorner)
            } else {
                mask.remove(.layerMaxXMaxYCorner)
            }
        default:
            break
        }
        
        layer.maskedCorners = mask
        layer.masksToBounds = true
    }
    
    // MARK: - Public Methods
    
    /// Apply rounded corners to specific corners with radius
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    /// Apply shadow with custom parameters
    func applyShadow(color: UIColor, opacity: Float, radius: CGFloat, offset: CGSize) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
        layer.masksToBounds = false
    }
    
    /// Remove all shadows
    func removeShadow() {
        layer.shadowColor = nil
        layer.shadowOpacity = 0
        layer.shadowRadius = 0
        layer.shadowOffset = .zero
    }
    
    /// Add border with color and width
    func addBorder(color: UIColor, width: CGFloat) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
    /// Remove border
    func removeBorder() {
        layer.borderColor = nil
        layer.borderWidth = 0
    }
    
    /// Apply gradient background
    func applyGradient(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0.5, y: 0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        // Remove existing gradient
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    /// Remove gradient background
    func removeGradient() {
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
    }
    
    // MARK: - Lifecycle Methods
    
    internal func webViewAwakeFromNib() {
        updateBorderColor()
        updateShadowColor()
        updateBackgroundColor()
    }
    
    internal func webViewPrepareForInterfaceBuilder() {
        updateBorderColor()
        updateShadowColor()
        updateBackgroundColor()
    }
}

// MARK: - Method Swizzling for WKWebView
extension WKWebView {
    static func swizzleWebViewMethods() {
        let originalAwake = class_getInstanceMethod(WKWebView.self, #selector(awakeFromNib))
        let swizzledAwake = class_getInstanceMethod(WKWebView.self, #selector(swizzled_webViewAwakeFromNib))
        
        if let original = originalAwake, let swizzled = swizzledAwake {
            method_exchangeImplementations(original, swizzled)
        }
        
        let originalPrepare = class_getInstanceMethod(WKWebView.self, #selector(prepareForInterfaceBuilder))
        let swizzledPrepare = class_getInstanceMethod(WKWebView.self, #selector(swizzled_webViewPrepareForInterfaceBuilder))
        
        if let original = originalPrepare, let swizzled = swizzledPrepare {
            method_exchangeImplementations(original, swizzled)
        }
    }
    
    @objc private func swizzled_webViewAwakeFromNib() {
        swizzled_webViewAwakeFromNib()
        webViewAwakeFromNib()
    }
    
    @objc private func swizzled_webViewPrepareForInterfaceBuilder() {
        swizzled_webViewPrepareForInterfaceBuilder()
        webViewPrepareForInterfaceBuilder()
    }
}

// MARK: - Convenience Initializers
public extension WKWebView {
    /// Convenience initializer with configuration and background color
    convenience init(configuration: WKWebViewConfiguration? = nil, backgroundColor: UIColor) {
        let config = configuration ?? WKWebViewConfiguration()
        self.init(frame: .zero, configuration: config)
        self.backgroundColor = backgroundColor
    }
    
    /// Convenience initializer with corner radius
    convenience init(cornerRadius: CGFloat, configuration: WKWebViewConfiguration? = nil) {
        let config = configuration ?? WKWebViewConfiguration()
        self.init(frame: .zero, configuration: config)
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
    
    /// Convenience initializer with border
    convenience init(borderColor: UIColor, borderWidth: CGFloat, configuration: WKWebViewConfiguration? = nil) {
        let config = configuration ?? WKWebViewConfiguration()
        self.init(frame: .zero, configuration: config)
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
    }
}
