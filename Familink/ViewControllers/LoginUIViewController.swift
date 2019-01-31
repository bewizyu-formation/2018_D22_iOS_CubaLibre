//
//  LoginUIViewController.swift
//  Familink
//
//  Created by formation 1 on 24/01/2019.
//  Copyright © 2019 CubaLibre. All rights reserved.
//

import UIKit
import CoreData

class LoginUIViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var loginBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginTextField.delegate = self
        passwordTextField.delegate = self
        
        self.initViewUI()
        NotificationCenter.default.addObserver(self, selector: #selector(onDidUserDisconnect(_:)), name: .didUserDisconnect, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func onSignUpButtonTap(_ sender: Any) {
        let signUpController = SignUpViewController(nibName:nil, bundle: nil)
        self.navigationController?.pushViewController(signUpController, animated: true)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func onForgotPasswordButtonTap(_ sender: Any) {
        let forgotPasswordController = ForgottenPasswordViewController(nibName:nil, bundle: nil)
        self.navigationController?.pushViewController(forgotPasswordController, animated: true)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func onLoginButtonTap(_ sender: Any) {
        let loader = UIViewController.displaySpinner(onView: self.view)
        
        UIView.animate(withDuration: -1, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            APIClient.instance.getToken(login: self.loginTextField.text ?? "", password: self.passwordTextField.text ?? "", onSuccess: { (token) in
                DispatchQueue.main.async {
                    UIViewController.removeSpinner(spinner: loader)
                    UIView.animate(withDuration: 2, animations: {
                        self.logInButton.setTitle("Connecté", for: .normal)
                        self.logInButton.backgroundColor = .green
                        self.loginBottomConstraint.constant = 0
                        UIView.animate(withDuration: 2, animations: {
                            self.loginTextField.isHidden = true
                            self.passwordTextField.isHidden = true
                            self.forgotPasswordButton.isHidden = true
                            self.signUpButton.isHidden = true
                            self.view.layoutIfNeeded()
                            self.saveTokenInCoreData(tokenToSave: token)
                            NotificationCenter.default.post(name: .didUserConnect, object: nil)
                        })
                    })
                }
            }) { (error) in
                DispatchQueue.main.async {
                    UIViewController.removeSpinner(spinner: loader)
                    UIView.animate(withDuration: -1, animations: {
                        self.logInButton.setTitle("Réessayer", for: .normal)
                        self.logInButton.backgroundColor = .red
                        let alert = UIAlertController(title: error, message: "", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    })
                }
            }
        }
    }

    @objc func onDidUserDisconnect(_ notification:Notification) {
        print("disconnet")
        self.navigationController?.isNavigationBarHidden = true
        self.logInButton.backgroundColor = UIColor.rosyBrown
        self.logInButton.setTitle("Se connecter", for: .normal)
        self.loginBottomConstraint.constant = 120
        
        self.loginTextField.isHidden = false
        self.passwordTextField.isHidden = false
        self.forgotPasswordButton.isHidden = false
        self.signUpButton.isHidden = false
        
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    func initViewUI() {
        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = .seaShell
        
        self.loginTextField.textColor = .rosyBrown
        self.loginTextField.layer.borderColor = UIColor.rosyBrown.cgColor
        self.loginTextField.layer.borderWidth = 1.0
        
        self.passwordTextField.textColor = .rosyBrown
        self.passwordTextField.layer.borderColor = UIColor.rosyBrown.cgColor
        self.passwordTextField.layer.borderWidth = 1.0
        
        self.logInButton.layer.cornerRadius = logInButton.frame.height/2
        self.logInButton.backgroundColor = .oldRose
        self.logInButton.setTitleColor(.seaShell, for: .normal)
        self.logInButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.logInButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.logInButton.layer.shadowOpacity = 1.0
        
        self.signUpButton.setTitleColor(.oldRose, for: .normal)
        self.forgotPasswordButton.setTitleColor(.oldRose, for: .normal)
        
    }
    
    func saveTokenInCoreData(tokenToSave : String) {
        let context = getContext()
        let fetchRequest: NSFetchRequest<Token> = Token.fetchRequest()
        if let result = try? context!.fetch(fetchRequest) {
            for object in result {
                context!.delete(object)
            }
        }
        
        let token = Token(context: context!)
        token.value = tokenToSave
        
        try? context?.save()
    }
    
    func getContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let nextTag = textField.tag + 1
        
        if let nextResponder = view.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
