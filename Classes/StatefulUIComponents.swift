//
//  StatefulUIComponents.swift
//
//  Created by Siarhei Lukyanau on 23.12.25.
//

import UIKit

public final class StatefulUIComponents {
    public static func initialize() {
        UIView.swizzleMethods()
        WKWebView.swizzleWebViewMethods()
    }
}
