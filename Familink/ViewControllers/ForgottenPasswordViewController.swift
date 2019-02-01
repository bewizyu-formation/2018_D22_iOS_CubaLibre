//
//  ForgottenPasswordViewController.swift
//  Familink
//
//  Created by formation 1 on 25/01/2019.
//  Copyright © 2019 CubaLibre. All rights reserved.
//

import UIKit

class ForgottenPasswordViewController: UIViewController {
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardGesture()
    }
    
    @IBAction func onResetPasswordTap(_ sender: Any) {
        let loader = UIViewController.displaySpinner(onView: self.view)
        
        UIView.animate(withDuration: -1, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            APIClient.instance.forgotPassword(phone: self.phoneTextField.text ?? "", onSuccess: { (success) in
                DispatchQueue.main.async {
                    UIViewController.removeSpinner(spinner: loader)
                    UIView.animate(withDuration: 2, animations: {
                        self.resetPasswordButton.backgroundColor = .green
                        UIView.animate(withDuration: 2, animations: {
                            self.resetPasswordButton.backgroundColor = .oldRose
                        })
                    })
                }
            }, onError: { (error) in
                DispatchQueue.main.async {
                    UIViewController.removeSpinner(spinner: loader)
                    UIView.animate(withDuration: -1, animations: {
                        let alert = UIAlertController(title: error, message: "", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    })
                }
            })
        }
    }
    
    func initViewUI() {
        self.view.backgroundColor = .seaShell
        
        self.infoLabel.textColor = .rosyBrown
        
        self.phoneTextField.textColor = .rosyBrown
        self.phoneTextField.layer.borderColor = UIColor.rosyBrown.cgColor
        self.phoneTextField.layer.borderWidth = 1.0
        
        self.resetPasswordButton.layer.cornerRadius = resetPasswordButton.frame.height/2
        self.resetPasswordButton.backgroundColor = .oldRose
        self.resetPasswordButton.setTitleColor(.seaShell, for: .normal)
        self.resetPasswordButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.resetPasswordButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.resetPasswordButton.layer.shadowOpacity = 1.0
    }
}
