//
//  WebKit+IBInspectable.swift
//
//  Created by Siarhei Lukyanau on 31.12.25.
//

import WebKit
import UIKit

// MARK: - Associated Keys
private struct WKWebViewAssociatedKeys {
    static var borderColorName = "borderColorName"
    static var cornerRadiusName = "cornerRadiusName"
    static var shadowColorName = "shadowColorName"
}

// MARK: - IBInspectable Extension for WKWebView
public extension WKWebView {
    
    // MARK: - Border Properties
    
    /// Border color through named colors (Interface Builder compatible)
    @IBInspectable var borderColorName: String? {
        get {
            return objc_getAssociatedObject(self, &WKWebViewAssociatedKeys.borderColorName) as? String
        }
        set {
            objc_setAssociatedObject(self, &WKWebViewAssociatedKeys.borderColorName, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateBorderColor()
        }
    }
    
    /// Border color through UIColor (Interface Builder compatible)
    @IBInspectable var borderUIColor: UIColor? {
        get {
            guard let cgColor = layer.borderColor else { return nil }
            return UIColor(cgColor: cgColor)
        }
        set {
            layer.borderColor = newValue?.cgColor
            if newValue != nil {
                borderColorName = nil // Clear named color when using direct color
            }
        }
    }
    
    /// Border width (Interface Builder compatible)
    @IBInspectable var borderWidthIB: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    // MARK: - Corner Radius Properties
    
    /// Corner radius (Interface Builder compatible)
    @IBInspectable var cornerRadiusIB: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            if cornerRadiusIB > 0 {
                layer.masksToBounds = true
            }
        }
    }
    
    /// Individual corner properties for Interface Builder
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
    
    // MARK: - Shadow Properties
    
    /// Shadow color through named colors (Interface Builder compatible)
    @IBInspectable var shadowColorName: String? {
        get {
            return objc_getAssociatedObject(self, &WKWebViewAssociatedKeys.shadowColorName) as? String
        }
        set {
            objc_setAssociatedObject(self, &WKWebViewAssociatedKeys.shadowColorName, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateShadowColor()
        }
    }
    
    /// Shadow color through UIColor (Interface Builder compatible)
    @IBInspectable var shadowUIColor: UIColor? {
        get {
            guard let cgColor = layer.shadowColor else { return nil }
            return UIColor(cgColor: cgColor)
        }
        set {
            layer.shadowColor = newValue?.cgColor
            if newValue != nil {
                shadowColorName = nil
            }
        }
    }
    
    /// Shadow offset (Interface Builder compatible)
    @IBInspectable var shadowOffsetIB: CGSize {
        get { return layer.shadowOffset }
        set { layer.shadowOffset = newValue }
    }
    
    /// Shadow opacity (Interface Builder compatible)
    @IBInspectable var shadowOpacityIB: Float {
        get { return layer.shadowOpacity }
        set { layer.shadowOpacity = newValue }
    }
    
    /// Shadow radius (Interface Builder compatible)
    @IBInspectable var shadowRadiusIB: CGFloat {
        get { return layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }
    
    // MARK: - Background Color for WebView Content
    
    /// Background color name for web content (affects webpage background)
    @IBInspectable var webBackgroundColorName: String? {
        get {
            return objc_getAssociatedObject(self, &WKWebViewAssociatedKeys.cornerRadiusName) as? String
        }
        set {
            objc_setAssociatedObject(self, &WKWebViewAssociatedKeys.cornerRadiusName, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateWebBackgroundColor()
        }
    }
    
    /// Background color for web content through UIColor
    @IBInspectable var webBackgroundUIColor: UIColor? {
        get {
            return self.backgroundColor
        }
        set {
            self.backgroundColor = newValue
            if newValue != nil {
                webBackgroundColorName = nil
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
    
    private func updateWebBackgroundColor() {
        guard let colorName = webBackgroundColorName, let color = UIColor(named: colorName) else {
            return
        }
        self.backgroundColor = color
    }
    
    // MARK: - WebView Specific Methods
    
    /// Apply CSS to change background color of web content
    func setWebContentBackgroundColor(_ color: UIColor) {
        let cssString = "body { background-color: \(color.hexString); }"
        let jsString = """
        var style = document.createElement('style');
        style.innerHTML = '\(cssString)';
        document.head.appendChild(style);
        """
        evaluateJavaScript(jsString, completionHandler: nil)
    }
    
    /// Clear web view cache and cookies
    func clearCacheAndCookies() {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: records) {
                print("WebView cache cleared")
            }
        }
    }
    
    /// Load HTML string with custom CSS styling
    func loadHTMLStringWithStyle(_ string: String, baseURL: URL? = nil, css: String = "") {
        let styledHTML = """
        <html>
            <head>
                <style>\(css)</style>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
            </head>
            <body>\(string)</body>
        </html>
        """
        loadHTMLString(styledHTML, baseURL: baseURL)
    }
    
    // MARK: - Lifecycle Methods
    
    internal func webViewAwakeFromNib() {
        updateBorderColor()
        updateShadowColor()
        updateWebBackgroundColor()
    }
    
    internal func webViewPrepareForInterfaceBuilder() {
        updateBorderColor()
        updateShadowColor()
        updateWebBackgroundColor()
        
        // Load sample content for Interface Builder preview
        let sampleHTML = """
        <html>
            <body style="background-color: #f0f0f0; color: #333; font-family: -apple-system; padding: 20px;">
                <h1>WKWebView Preview</h1>
                <p>This is a preview in Interface Builder</p>
            </body>
        </html>
        """
        loadHTMLString(sampleHTML, baseURL: nil)
    }
}

// MARK: - UIColor Extension for Hex Conversion
private extension UIColor {
    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        
        return String(format: "#%06x", rgb)
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
    /// Convenience initializer with configuration
    convenience init(frame: CGRect = .zero, configuration: WKWebViewConfiguration? = nil) {
        let config = configuration ?? WKWebViewConfiguration()
        self.init(frame: frame, configuration: config)
    }
    
    /// Create WKWebView with custom user agent
    static func withCustomUserAgent(_ userAgent: String) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.applicationNameForUserAgent = userAgent
        return WKWebView(frame: .zero, configuration: config)
    }
}

// MARK: - Usage Example
class WebViewViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply swizzling (call once, e.g., in AppDelegate)
        WKWebView.swizzleWebViewMethods()
        
        // Configure web view through IBInspectable properties
        // These can be set directly in Interface Builder
        webView.cornerRadiusIB = 8
        webView.borderWidthIB = 1
        webView.borderColorName = "BorderColor"
        webView.webBackgroundColorName = "BackgroundColor"
        
        // Load content
        if let url = URL(string: "https://example.com") {
            webView.load(URLRequest(url: url))
        }
    }
}
