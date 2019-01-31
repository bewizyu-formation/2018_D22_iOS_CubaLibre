//
//  KeyboardGesture.swift
//  Familink
//
//  Created by formation9 on 31/01/2019.
//  Copyright © 2019 CubaLibre. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func hideKeyboardGesture() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        swipe.direction = UISwipeGestureRecognizer.Direction.down
        swipe.cancelsTouchesInView = false
        view.addGestureRecognizer(swipe)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
