//
//  WebKit+IBInspectable.swift
//
//  Created by Siarhei Lukyanau on 23.12.25.
//

import WebKit

// MARK: - Associated Keys
private struct UIViewAssociatedKeys {
    static var borderColorName = "borderColorName"
}

// MARK: - IBInspectable Extension
public extension WebKit {
    
    // MARK: - Border Color через named colors
    @IBInspectable var borderColorName: String? {
        get {
            return objc_getAssociatedObject(self, &UIViewAssociatedKeys.borderColorName) as? String
        }
        set {
            objc_setAssociatedObject(self, &UIViewAssociatedKeys.borderColorName, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateBorderColor()
        }
    }
    
    // MARK: - Border Color через обычный цвет
    @IBInspectable var borderUIColor: UIColor? {
        get {
            if let cgColor = layer.borderColor {
                return UIColor(cgColor: cgColor)
            }
            return nil
        }
        set {
            layer.borderColor = newValue?.cgColor
            if newValue != nil {
                borderColorName = nil
            }
        }
    }
    
    // MARK: - Border Width
    @IBInspectable var borderWidthIB: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    // MARK: - Corner Radius
    @IBInspectable var cornerRadiusIB: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
    }
    
    // MARK: - Masked Corners (для отдельных углов)
    var maskedCornersIB: CACornerMask {
        get { return layer.maskedCorners }
        set { layer.maskedCorners = newValue }
    }
    
    // MARK: - Convenience properties для отдельных углов
    @IBInspectable var topLeftCorner: Bool {
        get { return layer.maskedCorners.contains(.layerMinXMinYCorner) }
        set {
            var corners = layer.maskedCorners
            if newValue {
                corners.insert(.layerMinXMinYCorner)
            } else {
                corners.remove(.layerMinXMinYCorner)
            }
            layer.maskedCorners = corners
        }
    }
    
    @IBInspectable var topRightCorner: Bool {
        get { return layer.maskedCorners.contains(.layerMaxXMinYCorner) }
        set {
            var corners = layer.maskedCorners
            if newValue {
                corners.insert(.layerMaxXMinYCorner)
            } else {
                corners.remove(.layerMaxXMinYCorner)
            }
            layer.maskedCorners = corners
        }
    }
    
    @IBInspectable var bottomLeftCorner: Bool {
        get { return layer.maskedCorners.contains(.layerMinXMaxYCorner) }
        set {
            var corners = layer.maskedCorners
            if newValue {
                corners.insert(.layerMinXMaxYCorner)
            } else {
                corners.remove(.layerMinXMaxYCorner)
            }
            layer.maskedCorners = corners
        }
    }
    
    @IBInspectable var bottomRightCorner: Bool {
        get { return layer.maskedCorners.contains(.layerMaxXMaxYCorner) }
        set {
            var corners = layer.maskedCorners
            if newValue {
                corners.insert(.layerMaxXMaxYCorner)
            } else {
                corners.remove(.layerMaxXMaxYCorner)
            }
            layer.maskedCorners = corners
        }
    }
    
    // MARK: - Private methods
    private func updateBorderColor() {
        guard let colorName = borderColorName, let color = UIColor(named: colorName) else {
            return
        }
        layer.borderColor = color.cgColor
    }
    
    // Вызывается после загрузки из Storyboard
    internal func ibAwakeFromNib() {
        updateBorderColor()
    }
    
    // Для отображения в Interface Builder
    internal func ibPrepareForInterfaceBuilder() {
        updateBorderColor()
    }
}

// MARK: - Method Swizzling для автоматического вызова
extension UIView {
    static func swizzleMethods() {
        let originalAwake = class_getInstanceMethod(UIView.self, #selector(awakeFromNib))
        let swizzledAwake = class_getInstanceMethod(UIView.self, #selector(swizzled_awakeFromNib))
        method_exchangeImplementations(originalAwake!, swizzledAwake!)
        
        let originalPrepare = class_getInstanceMethod(UIView.self, #selector(prepareForInterfaceBuilder))
        let swizzledPrepare = class_getInstanceMethod(UIView.self, #selector(swizzled_prepareForInterfaceBuilder))
        method_exchangeImplementations(originalPrepare!, swizzledPrepare!)
    }
    
    @objc private func swizzled_awakeFromNib() {
        swizzled_awakeFromNib()
        ibAwakeFromNib()
    }
    
    @objc private func swizzled_prepareForInterfaceBuilder() {
        swizzled_prepareForInterfaceBuilder()
        ibPrepareForInterfaceBuilder()
    }
}
