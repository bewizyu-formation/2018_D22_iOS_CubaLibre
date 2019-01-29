//
//  ContactDetailsViewController.swift
//  Familink
//
//  Created by formation 1 on 25/01/2019.
//  Copyright © 2019 CubaLibre. All rights reserved.
//

import UIKit
import MessageUI

class ContactDetailsViewController: UIViewController {
    @IBOutlet weak var gravatarView: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var phoneTitleLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailTitleLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var isFamilinkUserLabel: UILabel!
    @IBOutlet weak var isEmergencyUserLabel: UILabel!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    var contact: Contact!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initViewContent()
        self.initViewUI()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"edit"), style: .plain, target: self, action: #selector(onEditButtonPressed))
    }
    
    @IBAction func onEditButtonPressed() {
        let editContactController = EditContactViewController(nibName:nil, bundle: nil)
        self.navigationController?.pushViewController(editContactController, animated: true)
    }
    
    @IBAction func onMessageButtonTap(_ sender: Any) {
    }
    
    @IBAction func onCallButtonTap(_ sender: Any) {
        guard let number = URL(string: "tel://" + contact.phone!) else { return }
        if (UIApplication.shared.canOpenURL(number)){
            UIApplication.shared.open(number)
        }
        else {
            let alert = UIAlertController(title: "Désolé !", message: "Votre téléphone ne supporte pas de passer des appels", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onEmailButtonTap(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            guard let contactEmail = contact.email else {
                return
            }
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self as? MFMailComposeViewControllerDelegate
            mail.setToRecipients([contactEmail])
            self.present(mail, animated: true)
        } else {
            let alert = UIAlertController(title: "Désolé !", message: "Votre téléphone ne supporte pas l'envoi d'email", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func initViewContent() {
        firstNameLabel.text = contact.firstName
        lastNameLabel.text = contact.lastName
        phoneLabel.text = contact.phone
        emailLabel.text = contact.email
        isFamilinkUserLabel.isHidden = !contact.isFamilinkUser
        isEmergencyUserLabel.isHidden = !contact.isEmergencyUser
    }
    
    func initViewUI() {
        self.navigationController?.navigationBar.barTintColor = .rosyBrown
        self.navigationController?.navigationBar.tintColor = .seaShell
        self.view.backgroundColor = .seaShell
        
        firstNameLabel.textColor = .oldRose
        lastNameLabel.textColor = .oldRose
        
        phoneTitleLabel.textColor = .oldRose
        phoneLabel.textColor = .rosyBrown
        
        emailTitleLabel.textColor = .oldRose
        emailLabel.textColor = .rosyBrown
        
        isFamilinkUserLabel.textColor = .rosyBrown
        isEmergencyUserLabel.textColor = .rosyBrown
        
        messageButton.layer.cornerRadius = messageButton.frame.height/2
        messageButton.backgroundColor = .rosyBrown
        messageButton.setTitleColor(.seaShell, for: .normal)
        messageButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        messageButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        messageButton.layer.shadowOpacity = 1.0
        
        callButton.layer.cornerRadius = callButton.frame.height/2
        callButton.backgroundColor = .oldRose
        callButton.setTitleColor(.seaShell, for: .normal)
        callButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        callButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        callButton.layer.shadowOpacity = 1.0
        
        emailButton.layer.cornerRadius = emailButton.frame.height/2
        emailButton.backgroundColor = .rosyBrown
        emailButton.setTitleColor(.seaShell, for: .normal)
        emailButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        emailButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        emailButton.layer.shadowOpacity = 1.0
    }
}
