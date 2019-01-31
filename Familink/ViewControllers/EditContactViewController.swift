//
//  EditContactViewController.swift
//  Familink
//
//  Created by formation 1 on 25/01/2019.
//  Copyright © 2019 CubaLibre. All rights reserved.
//

import UIKit
import CoreData

class EditContactViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var firstNameTextInput: UITextField!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var lastNameTextInput: UITextField!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var phoneTextInput: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextInput: UITextField!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var profilePicker: UIPickerView!
    var profilePickerData: [String] = [String]()
    @IBOutlet weak var isFamilinkUserLabel: UILabel!
    @IBOutlet weak var isFamilinkUserSwitch: UISwitch!
    @IBOutlet weak var isEmergencyUserLabel: UILabel!
    @IBOutlet weak var isEmergencyUserSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    var contact: Contact!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardGesture()
        
        self.profilePicker.delegate = self
        self.profilePicker.dataSource = self
        
        firstNameTextInput.delegate = self
        lastNameTextInput.delegate = self
        phoneTextInput.delegate = self
        emailTextInput.delegate = self
        
        profilePickerData = ["Famille", "Senior", "Médecin"]
        
        self.initViewUI()
        self.initViewContent()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"delete"), style: .plain, target: self, action: #selector(onDeleteButtonPressed))
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return profilePickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return profilePickerData[row]
    }

    @IBAction func onValidateButtonPressed(_ sender: Any) {
        let loader = UIViewController.displaySpinner(onView: self.view)
        UIView.animate(withDuration: -1, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            self.saveButton.backgroundColor = .green
            UIView.animate(withDuration: -1, animations: {
                self.saveButton.backgroundColor = .rosyBrown
            }) { (_) in
                if(self.checkValidfields()){
                    let contactToUpdate = self.createContact()
                    self.updateContactOnCoreData(contactUpdated: contactToUpdate)
                    APIClient.instance.updateContact(token: getToken()!, contact: contactToUpdate, onSuccess: { (success) in
                        UIViewController.removeSpinner(spinner: loader)
                        DispatchQueue.main.async {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }, onError: { (error) in
                        UIViewController.removeSpinner(spinner: loader)
                        self.createErrorMessageAlert(title: error)
                    })
                } else {
                    UIViewController.removeSpinner(spinner: loader)
                    self.createErrorMessageAlert(title: "La saisie n'est pas correcte")
                }
            }
        }
    }
    
    func updateContactOnCoreData(contactUpdated : Contact){
        
        let context = getContext()!
        
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        fetchRequest.predicate = NSPredicate(format: "contactId == %@", contactUpdated.contactId!)
        
        let fetchedResults = try? context.fetch(fetchRequest)
        if let contactToUpdate = fetchedResults?.first {
            contactToUpdate.setValue(contactUpdated.firstName, forKey: "firstName")
            contactToUpdate.setValue(contactUpdated.lastName, forKey: "lastName")
            contactToUpdate.setValue(contactUpdated.phone, forKey: "phone")
            contactToUpdate.setValue(contactUpdated.email, forKey: "email")
            contactToUpdate.setValue(contactUpdated.profile, forKey: "profile")
            contactToUpdate.setValue(contactUpdated.isFamilinkUser, forKey: "isFamilinkUser")
            contactToUpdate.setValue(contactUpdated.isEmergencyUser, forKey: "isEmergencyUser")
            
            try? context.save()
        }
    }
    
    @objc func onDeleteButtonPressed() {
        let alert = UIAlertController(title: "Confirmer la suppression", message: "Voulez-vous vraiment supprimer \(contact.firstName!) \(contact.lastName ?? "") ?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .default, handler: nil))
        
        let validateDelete = UIAlertAction(title: "Supprimer", style: .destructive) { (action:UIAlertAction) in
            let loader = UIViewController.displaySpinner(onView: self.view)
            APIClient.instance.deleteContact(token: getToken()!, contactId: self.contact.contactId!, onSuccess: { (success) in
                UIViewController.removeSpinner(spinner: loader)
                self.deleteOnCoreData()
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }, onError: { (erreur) in
                UIViewController.removeSpinner(spinner: loader)
                self.createErrorMessageAlert(title: erreur)
            })
        }
        
        alert.addAction(validateDelete)
        
        self.present(alert, animated: true)
    }
    
    func deleteOnCoreData(){
        let context = getContext()!
        
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        fetchRequest.predicate = NSPredicate(format: "contactId == %@", self.contact.contactId!)
        
        let fetchedResults = try? context.fetch(fetchRequest)
        if let contactToDelete = fetchedResults?.first {
            context.delete(contactToDelete)
            
            try? context.save()
        }
    }
    
    func createContact() -> Contact {
        let contactUpdated = Contact(context: getContext()!)
        contactUpdated.contactId = contact.contactId
        contactUpdated.firstName = firstNameTextInput.text
        contactUpdated.lastName = lastNameTextInput.text
        contactUpdated.phone = phoneTextInput.text
        contactUpdated.email = emailTextInput.text
        contactUpdated.gravatar = contact.gravatar
        contactUpdated.profile = profilePickerData[profilePicker.selectedRow(inComponent: 0)]
        contactUpdated.isFamilinkUser = isFamilinkUserSwitch.isOn
        contactUpdated.isEmergencyUser = isEmergencyUserSwitch.isOn
        
        return contactUpdated
    }
    
    func getContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    func createErrorMessageAlert(title : String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func checkValidfields() -> Bool {
        var isValid = true
        
        if((firstNameTextInput.text?.count)! < 1){
            firstNameTextInput.layer.borderColor = UIColor.red.cgColor
            isValid = false
        }
        
        let phoneRegex = "^(0[67])(?:[ _.-]?([0-9]{2})){4}"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        if(!phoneTest.evaluate(with: phoneTextInput.text)){
            phoneTextInput.layer.borderColor = UIColor.red.cgColor
            isValid = false
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if((emailTextInput.text?.count)! > 0 && !emailTest.evaluate(with: emailTextInput.text)){
            emailTextInput.layer.borderColor = UIColor.red.cgColor
            isValid = false
        }
        
        return isValid
    }
    
    @IBAction func onFirstNameChange(_ sender: Any) {
        (sender as! UITextField).layer.borderColor = UIColor.rosyBrown.cgColor
    }
    
    @IBAction func onPhoneChange(_ sender: Any) {
        (sender as! UITextField).layer.borderColor = UIColor.rosyBrown.cgColor
    }
    
    @IBAction func onEmailChange(_ sender: Any) {
        (sender as! UITextField).layer.borderColor = UIColor.rosyBrown.cgColor
    }
    
    func initViewContent() {
        firstNameTextInput.text = contact.firstName
        lastNameTextInput.text = contact.lastName
        phoneTextInput.text = contact.phone
        emailTextInput.text = contact.email
        switch contact.profile {
        case "Famille":
            profilePicker.selectRow(0, inComponent: 0, animated: true)
        case "Senior":
            profilePicker.selectRow(1, inComponent: 0, animated: true)
        default:
            profilePicker.selectRow(2, inComponent: 0, animated: true)
        }
        isFamilinkUserSwitch.isOn = contact.isFamilinkUser
        isEmergencyUserSwitch.isOn = contact.isEmergencyUser
    }
    
    func initViewUI() {
        self.navigationController?.navigationBar.barTintColor = .rosyBrown
        self.navigationController?.navigationBar.tintColor = .seaShell
        self.view.backgroundColor = .seaShell
        
        firstNameLabel.textColor = .oldRose
        firstNameTextInput.textColor = .rosyBrown
        firstNameTextInput.layer.borderColor = UIColor.rosyBrown.cgColor
        firstNameTextInput.layer.borderWidth = 1.0
        
        lastNameLabel.textColor = .oldRose
        lastNameTextInput.textColor = .rosyBrown
        lastNameTextInput.layer.borderColor = UIColor.rosyBrown.cgColor
        lastNameTextInput.layer.borderWidth = 1.0
        
        phoneLabel.textColor = .oldRose
        phoneTextInput.textColor = .rosyBrown
        phoneTextInput.layer.borderColor = UIColor.rosyBrown.cgColor
        phoneTextInput.layer.borderWidth = 1.0
        
        emailLabel.textColor = .oldRose
        emailTextInput.textColor = .rosyBrown
        emailTextInput.layer.borderColor = UIColor.rosyBrown.cgColor
        emailTextInput.layer.borderWidth = 1.0
        
        profileLabel.textColor = .oldRose
        
        isFamilinkUserLabel.textColor = .oldRose
        isFamilinkUserSwitch.onTintColor = .oldRose
        
        isEmergencyUserLabel.textColor = .oldRose
        isEmergencyUserSwitch.onTintColor = .oldRose
        
        saveButton.layer.cornerRadius = saveButton.frame.height/2
        saveButton.backgroundColor = .oldRose
        saveButton.setTitleColor(.seaShell, for: .normal)
        saveButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        saveButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        saveButton.layer.shadowOpacity = 1.0
    }
}
