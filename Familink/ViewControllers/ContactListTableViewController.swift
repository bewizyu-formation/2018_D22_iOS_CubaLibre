//
//  ContactListTableViewController.swift
//  Familink
//
//  Created by formation 1 on 25/01/2019.
//  Copyright © 2019 CubaLibre. All rights reserved.
//

import UIKit
import MessageUI
import CoreData

class ContactListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var contacts = [Contact]()
    var fetchedResultController: NSFetchedResultsController<Contact>?
    @IBOutlet var searchBar: UITableView!

    // initialize

    func refresh() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    func getContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardGesture()

        self.tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.backgroundColor = UIColor.seaShell
    }
    
    @IBAction func onUserButtonPressed(_ sender: Any) {
        let userDetailsController = UserDetailsViewController(nibName:nil, bundle: nil)
        self.navigationController?.pushViewController(userDetailsController, animated: true)
    }
    
    @IBAction func addContactButtonPressed(_ sender: Any) {
        let addContactController = AddContactViewController(nibName:nil, bundle: nil)
        self.navigationController?.pushViewController(addContactController, animated: true)
    }
    
    @IBAction func onDisconnectButtonPress(_ sender: Any) {
        NotificationCenter.default.post(name: .didUserDisconnect, object: nil)
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
        
        DispatchQueue.global(qos: .background).async {
            guard let gravatar = contact.gravatar else {
                return
            }
            guard let url = URL(string: gravatar) else {
                return
            }
            guard let data = try? Data(contentsOf: url) else {
                return
            }
            
            DispatchQueue.main.async {
                cell.contactImage.image = UIImage(data: data)
            }
        }

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
