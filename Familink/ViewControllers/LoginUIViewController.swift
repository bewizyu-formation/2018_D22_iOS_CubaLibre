//
//  LoginUIViewController.swift
//  Familink
//
//  Created by formation 1 on 24/01/2019.
//  Copyright © 2019 CubaLibre. All rights reserved.
//

import UIKit

class LoginUIViewController: UIViewController {
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var loginConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidUserDisconnect(_:)), name: .didUserDisconnect, object: nil)
        // Do any additional setup after loading the view.
        
        logInButton.layer.cornerRadius = logInButton.frame.height/2
    }
    
    @IBAction func SignUpButton(_ sender: Any) {
        
        let signUpController = SignUpViewController(nibName:nil, bundle: nil)
        self.navigationController?.pushViewController(signUpController, animated: true)
       
    }
    
    @IBAction func ForgotPassButton(_ sender: Any) {
        let forgotPasswordController = ForgottenPasswordViewController(nibName:nil, bundle: nil)
        self.navigationController?.pushViewController(forgotPasswordController, animated: true)
    }
    
    @IBAction func userNav(_ sender: Any) {
    }
    @IBAction func LoginButton(_ sender: Any) {
        
        loginConstraint.constant = 30
        logInButton.setTitle("", for: .normal)
        UIView.animate(withDuration: -1, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            self.logInButton.titleLabel?.alpha = 0
            self.logInButton.setTitle("Connecté", for: .normal)
            UIView.animate(withDuration: 2, animations: {
                self.logInButton.titleLabel?.alpha = 1
                self.logInButton.backgroundColor = .green
            }) { (_) in
                NotificationCenter.default.post(name: .didUserConnect, object: nil)
            }
        }
        
        
    }
    
    @objc func onDidUserDisconnect(_ notification:Notification) {
        self.navigationController?.popToRootViewController(animated: false)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
