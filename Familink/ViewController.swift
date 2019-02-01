//
//  ViewController.swift
//  Familink
//
//  Created by formation9 on 23/01/2019.
//  Copyright © 2019 CubaLibre. All rights reserved.
//

import UIKit
import CoreData

extension Notification.Name {
    static let didUserConnect = Notification.Name("didUserConnect")
    static let didUserDisconnect = Notification.Name("didUserDisconnect")
}

class ViewController: UIViewController {
    private var token : String = ""
    
    @IBOutlet weak var LoginContainerView: UIView!
    @IBOutlet weak var ContactListContainerView: UIView!
    
    var isConnected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onDidUserConnect(_:)), name: .didUserConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidUserDisconnect(_:)), name: .didUserDisconnect, object: nil)
    }
    
    @objc func onDidUserConnect(_ notification:Notification) {
        isConnected = true
        toggleUINavigation()
    }
    
    @objc func onDidUserDisconnect(_ notification:Notification) {
        isConnected = false
        resetCoreData()
        toggleUINavigation()
    }
    
    func resetCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        
        let results = try? context.fetch(fetchRequest)
        
        guard let contactList = results else {
            return
        }
        
        for contact in contactList{
            context.delete(contact)
        }
        
        let userFetchRequest = NSFetchRequest<User>(entityName: "User")
        
        let userResults = try? context.fetch(userFetchRequest)
        
        guard let users = userResults else {
            return
        }
        
        for user in users {
            context.delete(user)
        }
        
        let tokenFetchRequest = NSFetchRequest<Token>(entityName: "Token")
        
        let tokenResults = try? context.fetch(tokenFetchRequest)
        
        guard let tokens = tokenResults else {
            return
        }
        
        for token in tokens {
            context.delete(token)
        }
        
        try? context.save()
    }
    
    func toggleUINavigation() {
        if (isConnected)
        {
            UIView.animate(withDuration: -1, animations: {
                self.LoginContainerView.alpha = 0
                self.ContactListContainerView.alpha = 1
            })
        }
        else {
            UIView.animate(withDuration: -1, animations: {
                self.LoginContainerView.alpha = 1
                self.ContactListContainerView.alpha = 0
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        toggleUINavigation()
    }
}
