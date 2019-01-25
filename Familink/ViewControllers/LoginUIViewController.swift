//
//  LoginUIViewController.swift
//  Familink
//
//  Created by formation 1 on 24/01/2019.
//  Copyright © 2019 CubaLibre. All rights reserved.
//

import UIKit

class LoginUIViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onDidUserDisconnect(_:)), name: .didUserDisconnect, object: nil)
        // Do any additional setup after loading the view.
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
        NotificationCenter.default.post(name: .didUserConnect, object: nil)
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
