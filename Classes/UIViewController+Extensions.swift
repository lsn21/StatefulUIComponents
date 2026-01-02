//
//  UIViewController+Extensions.swift
//  StatefulUIComponents
//
//  Created by Siarhei Lukyanau on 2.01.26.
//

import UIKit

extension UIViewController {
    
    func dismissKeyboard() {
        
        let tapG: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboardTouchOutside))
    
        tapG.cancelsTouchesInView = false
        print("cancelsTouchesInView")
        print("addGestureRecognizer")
        view.addGestureRecognizer(tapG)
    }
    
    @objc private func dismissKeyboardTouchOutside() {
        print("dismissKeyboardTouchOutside")
        printKeyboardTouchOutside()
        view.endEditing(true)
    }
    
    private func printKeyboardTouchOutside() {
        print("dismissKeyboardTouchOutside")
    }
}
