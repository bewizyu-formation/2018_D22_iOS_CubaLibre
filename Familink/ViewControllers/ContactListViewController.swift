//
//  ContactListViewController.swift
//  Familink
//
//  Created by formation 1 on 30/01/2019.
//  Copyright © 2019 CubaLibre. All rights reserved.
//

import UIKit
import CoreData

class ContactListViewController: UIViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate {

    var contacts = [Contact]()
    var filteredContacts = [Contact]()
    var fetchedResultController: NSFetchedResultsController<Contact>?
    @IBOutlet weak var containerView: UIView!
    
    var tableView: ContactListTableViewController!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var filterByCategory = ""
    var filterByName = ""
    
    // IBActions
    
    @IBAction func onAllFilterPressed(_ sender: Any) {
        filterByCategory = ""
        filterContacts()
        refresh()
    }
    @IBAction func onFamilyFilterPressed(_ sender: Any) {
        filterByCategory = "FAMILLE"
        filterContacts()
        refresh()
    }
    @IBAction func onSeniorFilterPressed(_ sender: Any) {
        filterByCategory = "SENIOR"
        filterContacts()
        refresh()
    }
    @IBAction func onMedicFilterPressed(_ sender: Any) {
        filterByCategory = "MEDECIN"
        filterContacts()
        refresh()
    }
    @IBAction func onUrgencyFilterPressed(_ sender: Any) {
        filterByCategory = "URGENCY"
        filterContacts()
        refresh()
    }
    
    @IBAction func onAddContactButtonPressed(_ sender: Any) {
        let addContactController = AddContactViewController(nibName:nil, bundle: nil)
        self.navigationController?.pushViewController(addContactController, animated: true)
    }
    
    @IBAction func onProfileButtonPressed(_ sender: Any) {
        let userDetailsController = UserDetailsViewController(nibName:nil, bundle: nil)
        self.navigationController?.pushViewController(userDetailsController, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterByName = searchText.lowercased()
        filterContacts()
        refresh()
    }
    
    // Part Filter & refresh
    
    func filterContacts() {
        filteredContacts = contacts.filter {
            let fullName = ($0.firstName?.lowercased() ?? "") + " " + ($0.lastName?.lowercased() ?? "")
            if (filterByName != "" && !fullName.contains(filterByName)) {
                return false
            }
            if (filterByCategory != "" && filterByCategory != "URGENCY" && filterByCategory != $0.profile) {
                return false
            }
            else if filterByCategory == "URGENCY" {
                return $0.isEmergencyUser
            }
            return true
        }
    }
    
    func refresh() {
        self.tableView.contacts = self.filteredContacts
        self.tableView.tableView.reloadData()
    }
    
    // initialize
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? ContactListTableViewController {
            self.tableView = destination
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidUserConnect(_:)), name: .didUserConnect, object: nil)
        
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.tableView.backgroundColor = UIColor.seaShell
        getContactsFromCoreData()
    }
    
    // Contacts to & from coredata
    
    func getContactsFromCoreData() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        
        let resultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        resultController.delegate = self
        
        try? resultController.performFetch()
        
        contacts = resultController.fetchedObjects ?? []
        
        self.fetchedResultController = resultController
        
        filterContacts()
        refresh()
    }
    
    // set contacts to CoreData
    
    func setContactsToCoreData(contactList : [Contact]) {
        DispatchQueue.main.sync {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
        
            let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
            
            let results = try? context.fetch(fetchRequest)
            
            guard let previousContacts = results else {
                return
            }
            
            for contact in previousContacts{
                context.delete(contact)
            }
            
            for c in contactList {
                context.insert(c)
            }
            
            try? context.save()
            
            contacts = contactList
            
            getContactsFromCoreData() // permet de filtrer par ordre alphabétique
        }
    }

    @objc func onDidUserConnect(_ notification:Notification) {
        let token = getToken() ?? ""
        
        _ = APIClient.instance.getContactList(token: token, onSuccess: self.setContactsToCoreData, onError: self.contactsFromAPIErrorDidFetch)
    }
    
    func contactsFromAPIErrorDidFetch(error: String) {
        print("Error while fetching token")
        print("Error is : " + error)
    }
}
