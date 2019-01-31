//
//  ContactsListTableViewController.swift
//  Familink
//
//  Created by formation 1 on 30/01/2019.
//  Copyright © 2019 CubaLibre. All rights reserved.
//

import UIKit
import MessageUI

class ContactsListTableViewController: UITableViewController {

    var contacts = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // tableview
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as! ContactTableViewCell
        let contact = contacts[indexPath.row]
        
        cell.contactLabelTitle.text = (contact.firstName ?? "") + " " + (contact.lastName ?? "")
        cell.contactLabelTitle.layoutMargins = UIEdgeInsets(top: 0, left: 75, bottom: 0, right: 0)
        cell.backgroundColor = UIColor.seaShell
        cell.contactLabelTitleView.backgroundColor = UIColor.seaShell
        cell.contactLabelTitle.textColor = UIColor.oldRose
        
        guard let gravatar = contact.gravatar else {
            return cell
        }
        guard let url = URL(string: gravatar) else {
            return cell
        }
        guard let data = try? Data(contentsOf: url) else {
            return cell
        }
        cell.contactImage.image = UIImage(data: data)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ContactDetailsViewController(nibName:nil, bundle: nil)
        let contact = contacts[indexPath.row]
        vc.contact = contact //contacts[indexPath.row]
        
        
        self.show(vc, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt index: IndexPath) -> [UITableViewRowAction]? {
        
        let call = UITableViewRowAction(style: .normal, title: "Appeler") { action, index in
            
            guard let phone = self.contacts[index[1]].phone else { return }
            guard let number = URL(string: "tel://" + phone) else { return }
            if (UIApplication.shared.canOpenURL(number))
            {
                UIApplication.shared.open(number)
            }
            else {
                let alert = UIAlertController(title: "Désolé !", message: "Votre téléphone ne supporte pas de passer des appels", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        call.backgroundColor = .green
        
        let mail = UITableViewRowAction(style: .normal, title: "Envoyer un email") { action, index in
            if MFMailComposeViewController.canSendMail() {
                
                guard let contactEmail = self.contacts[index[1]].email else { return }
                
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
        mail.backgroundColor = .orange
        
        return [call, mail]
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
