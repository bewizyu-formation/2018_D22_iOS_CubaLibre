//
//  AddContactViewController.swift
//  Familink
//
//  Created by formation 1 on 25/01/2019.
//  Copyright © 2019 CubaLibre. All rights reserved.
//

import UIKit
import CoreData

class AddContactViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var firstNameTextInput: UITextField!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var lastNameTextInput: UITextField!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var phoneTextInput: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var profilePicker: UIPickerView!
    @IBOutlet weak var isFamilinkUserLabel: UILabel!
    @IBOutlet weak var isFamilinkUserSwitch: UISwitch!
    var profilePickerData: [String] = [String]()
    @IBOutlet weak var isEmergencyUserLabel: UILabel!
    @IBOutlet weak var isEmergencyUserSwitch: UISwitch!
    @IBOutlet weak var createContactButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profilePicker.delegate = self
        self.profilePicker.dataSource = self
        
        profilePickerData = ["Famille", "Senior", "Médecin"]
        
        self.initViewUI()
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

    @IBAction func onCreateContactButton(_ sender: Any) {
        
        if(!checkValidfields()){
            let alert = UIAlertController(title: "La saisie n'est pas valide", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        let contact = Contact(context: self.getContext()!)
        contact.firstName = firstNameTextInput.text
        contact.lastName = lastNameTextInput.text
        contact.phone = phoneTextInput.text
        contact.email = emailTextField.text
        contact.gravatar = "https://www.gravatar.com/avatar/601e257a31da0193b9bac803405f3664"
        contact.profile = profilePickerData[profilePicker.selectedRow(inComponent: 0)]
        contact.isFamilinkUser = isFamilinkUserSwitch.isOn
        contact.isEmergencyUser = isEmergencyUserSwitch.isOn
        
        let loader = UIViewController.displaySpinner(onView: self.view)
        APIClient.instance.addContact(token: getToken(), contact: contact, onSuccess: { (_) in
            UIViewController.removeSpinner(spinner: loader)
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }) { (error) in
            UIViewController.removeSpinner(spinner: loader)
            let alert = UIAlertController(title: error, message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        
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
        if((emailTextField.text?.count)! > 0 && !emailTest.evaluate(with: emailTextField.text)){
            emailTextField.layer.borderColor = UIColor.red.cgColor
            isValid = false
        }
        
        return isValid
    }

    @IBAction func onFirstNameFieldChange(_ sender: Any) {
        (sender as! UITextField).layer.borderColor = UIColor.rosyBrown.cgColor
    }
    
    @IBAction func onNumberFieldChange(_ sender: Any) {
        (sender as! UITextField).layer.borderColor = UIColor.rosyBrown.cgColor
    }
    
    @IBAction func onEmailFieldChange(_ sender: Any) {
        (sender as! UITextField).layer.borderColor = UIColor.rosyBrown.cgColor
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
        emailTextField.textColor = .rosyBrown
        emailTextField.layer.borderColor = UIColor.rosyBrown.cgColor
        emailTextField.layer.borderWidth = 1.0
        
        profileLabel.textColor = .oldRose
        
        isFamilinkUserLabel.textColor = .oldRose
        isFamilinkUserSwitch.onTintColor = .oldRose
        
        isEmergencyUserLabel.textColor = .oldRose
        isEmergencyUserSwitch.onTintColor = .oldRose
    
        createContactButton.layer.cornerRadius = createContactButton.frame.height/2
        createContactButton.backgroundColor = .oldRose
        createContactButton.setTitleColor(.seaShell, for: .normal)
        createContactButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        createContactButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        createContactButton.layer.shadowOpacity = 1.0
    }
    
    func getContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
}
