//
//  StatefulUIComponents.swift
//  StatefulUIComponents
//
//  Created by Siarhei Lukyanau on 31.12.25.
//

import UIKit
import WebKit

public final class StatefulUIComponents {
    public static func initialize() {
        UIView.swizzleViewMethods()
        WKWebView.swizzleWebViewMethods()
    }
}
