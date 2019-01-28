//
//  LoginUIViewController.swift
//  Familink
//
//  Created by formation 1 on 24/01/2019.
//  Copyright © 2019 CubaLibre. All rights reserved.
//

import UIKit

class LoginUIViewController: UIViewController {
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var loginConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidUserDisconnect(_:)), name: .didUserDisconnect, object: nil)
        // Do any additional setup after loading the view.
        
        logInButton.layer.cornerRadius = logInButton.frame.height/2
    }
    @IBAction func onSignUpButtonTap(_ sender: Any) {
        let signUpController = SignUpViewController(nibName:nil, bundle: nil)
        self.navigationController?.pushViewController(signUpController, animated: true)
    }
    
    @IBAction func onForgotPasswordButtonTap(_ sender: Any) {
        let forgotPasswordController = ForgottenPasswordViewController(nibName:nil, bundle: nil)
        self.navigationController?.pushViewController(forgotPasswordController, animated: true)
    }
    
    @IBAction func userNav(_ sender: Any) {
    }
    @IBAction func onLoginButtonTap(_ sender: Any) {
        UIView.animate(withDuration: -1, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            APIClient.instance.getToken(login: self.loginTextField.text ?? "", password: self.passwordTextField.text ?? "", onSuccess: { (success) in
                DispatchQueue.main.async {
                    UIView.animate(withDuration: -1, animations: {
                        self.logInButton.setTitle("Connecté", for: .normal)
                        self.logInButton.titleLabel?.alpha = 1
                        self.logInButton.backgroundColor = .green
                        NotificationCenter.default.post(name: .didUserConnect, object: nil)
                    })
                }
            }) { (error) in
                DispatchQueue.main.async {
                    UIView.animate(withDuration: -1, animations: {
                        self.logInButton.setTitle("Erreur", for: .normal)
                        self.logInButton.titleLabel?.alpha = 1
                        self.logInButton.backgroundColor = .red
                    })
                }
            }
        }
    }

    
    @objc func onDidUserDisconnect(_ notification:Notification) {
        print("disconnet")
        self.logInButton.setTitle("Se connecter", for: .normal)
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
