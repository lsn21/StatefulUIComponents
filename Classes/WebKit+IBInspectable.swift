//
//  WebKit+IBInspectable.swift
//
//  Created by Siarhei Lukyanau on 31.12.25.
//

import WebKit
import UIKit

// MARK: - Associated Keys for WKWebView specific properties
private struct WKWebViewAssociatedKeys {
    static var webBackgroundColorName = "webBackgroundColorName"
}

// MARK: - IBInspectable Extension for WKWebView (только специфичные свойства)
public extension WKWebView {
    
    // MARK: - WebView Specific Background Color Properties
    
    /// Background color name for web content (affects webpage background)
    @IBInspectable var webBackgroundColorName: String? {
        get {
            return objc_getAssociatedObject(self, &WKWebViewAssociatedKeys.webBackgroundColorName) as? String
        }
        set {
            objc_setAssociatedObject(self, &WKWebViewAssociatedKeys.webBackgroundColorName, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
        updateWebBackgroundColor()
    }
    
    internal func webViewPrepareForInterfaceBuilder() {
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
