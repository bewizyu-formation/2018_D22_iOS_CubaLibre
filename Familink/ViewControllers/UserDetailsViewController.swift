//
//  UserDetailsViewController.swift
//  Familink
//
//  Created by formation 1 on 25/01/2019.
//  Copyright © 2019 CubaLibre. All rights reserved.
//

import UIKit

class UserDetailsViewController: UIViewController {

    
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var phoneTitleLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var profileTitleLabel: UILabel!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var emailTitleLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var disconnectButton: UIButton!

    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initViewUI()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"edit"), style: .plain, target: self, action: #selector(onEditButtonPressed))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let token = getToken() {
            _ = APIClient.instance.getUser(token: token, onSuccess: self.onGetUserSuccess, onError: self.onGetUserError)
        }
    }
    
    @IBAction func onEditButtonPressed(_ sender: Any) {
        let editUserController = EditUserViewController(nibName:nil, bundle: nil)
    self.navigationController?.pushViewController(editUserController, animated: true)
    }
    
    func onGetUserSuccess (user: User) {
        DispatchQueue.main.async {
        self.phoneLabel.text = user.phone
        self.lastNameLabel.text = user.lastName
        self.firstNameLabel.text = user.firstName
        self.profileLabel.text = user.profile
        self.emailLabel.text = user.email
        }
    }
    
    func onGetUserError (message: String) {
        let alert = UIAlertController(title: "Erreur", message: "Utilisateur non récupéré", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func initViewUI() {
        self.navigationController?.navigationBar.barTintColor = .rosyBrown
        self.navigationController?.navigationBar.tintColor = .seaShell
        self.view.backgroundColor = .seaShell
        
        lastNameLabel.textColor = .oldRose
        firstNameLabel.textColor = .oldRose
        
        phoneTitleLabel.textColor = .oldRose
        phoneLabel.textColor = .rosyBrown
    
        profileTitleLabel.textColor = .oldRose
        profileLabel.textColor = .rosyBrown
     
        emailTitleLabel.textColor = .oldRose
        emailLabel.textColor = .rosyBrown
        
        disconnectButton.layer.cornerRadius = disconnectButton.frame.height/2
        disconnectButton.backgroundColor = .rosyBrown
        disconnectButton.setTitleColor(.seaShell, for: .normal)
        disconnectButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        disconnectButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        disconnectButton.layer.shadowOpacity = 1.0
    }
    
    @IBAction func onDisconnectButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: -1, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            self.disconnectButton.backgroundColor = .green
            UIView.animate(withDuration: -1, animations: {
                self.disconnectButton.backgroundColor = .rosyBrown
            })
        }
    NotificationCenter.default.post(name: .didUserDisconnect, object: nil)
    }

}
