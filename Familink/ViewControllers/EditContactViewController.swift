//
//  EditContactViewController.swift
//  Familink
//
//  Created by formation 1 on 25/01/2019.
//  Copyright © 2019 CubaLibre. All rights reserved.
//

import UIKit

class EditContactViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
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
        
        self.profilePicker.delegate = self
        self.profilePicker.dataSource = self
        
        profilePickerData = ["Famille", "Senior", "Médecin"]
        
        self.initViewUI()
        self.initViewContent()
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
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func initViewContent() {
        firstNameTextInput.text = contact.firstName
        lastNameTextInput.text = contact.lastName
        phoneTextInput.text = contact.phone
        emailTextInput.text = contact.email
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
