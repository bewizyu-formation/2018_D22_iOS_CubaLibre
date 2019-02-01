//
//  EditUserViewController.swift
//  Familink
//
//  Created by formation 1 on 25/01/2019.
//  Copyright © 2019 CubaLibre. All rights reserved.
//

import UIKit
import CoreData

class EditUserViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var lastNameTitleLabel: UILabel!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTitleLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var profileTitleLabel: UILabel!
    @IBOutlet weak var profileTextField: UITextField!
    @IBOutlet weak var pickerTextField: UITextField!
    @IBOutlet weak var emailTitleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var errorMessageLastNameLabel: UILabel!
    @IBOutlet weak var errorMessageFirstNameLabel: UILabel!
    @IBOutlet weak var errorMessageProfileLabel: UILabel!
    @IBOutlet weak var errorMessageEmailLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var validateButton: UIButton!
    
    var pickOption = ["Famille", "Senior", "Medecin"]
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerTextField.inputView = pickerView
        
        errorMessageLastNameLabel.isHidden = true
        errorMessageFirstNameLabel.isHidden = true
        errorMessageProfileLabel.isHidden = true
        errorMessageEmailLabel.isHidden = true
        
        pickerTextField.delegate = self
        
        lastNameTextField.delegate = self
        firstNameTextField.delegate = self
        profileTextField.delegate = self
        emailTextField.delegate = self
        
        registerForKeyboardNotifications()
        
        self.initViewContent()
        self.initViewUI()
        
    }
    
    func initViewContent() {
        if let token = getToken() {

            _ = APIClient.instance.getUser(token: token, onSuccess: onGetUserSuccess, onError: onGetUserError)
        }
    }
    
    func onGetUserSuccess (user: User) {
        DispatchQueue.main.async {
            self.lastNameTextField.text = user.lastName
            self.firstNameTextField.text = user.firstName
            self.profileTextField.text = user.profile
            self.emailTextField.text = user.email
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
        
        lastNameTitleLabel.textColor = .oldRose
        lastNameTextField.textColor = .rosyBrown
        lastNameTextField.layer.borderColor = UIColor.rosyBrown.cgColor
        lastNameTextField.layer.borderWidth = 1.0
        
        firstNameTitleLabel.textColor = .oldRose
        firstNameTextField.textColor = .rosyBrown
        firstNameTextField.layer.borderColor = UIColor.rosyBrown.cgColor
        firstNameTextField.layer.borderWidth = 1.0
        
        profileTitleLabel.textColor = .oldRose
        profileTextField.textColor = .rosyBrown
        profileTextField.layer.borderColor = UIColor.rosyBrown.cgColor
        profileTextField.layer.borderWidth = 1.0
        
        emailTitleLabel.textColor = .oldRose
        emailTextField.textColor = .rosyBrown
        emailTextField.layer.borderColor = UIColor.rosyBrown.cgColor
        emailTextField.layer.borderWidth = 1.0
        
        validateButton.layer.cornerRadius = validateButton.frame.height/2
        validateButton.backgroundColor = .rosyBrown
        validateButton.setTitleColor(.seaShell, for: .normal)
        validateButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        validateButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        validateButton.layer.shadowOpacity = 1.0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = pickOption[row] as String
    }
    
    @IBAction func onValidateButtonPressed(_ sender: Any) {
        
        var error = false
        
        if lastNameTextField.text == ""{
            error = true
            UIView.animate(withDuration: 0.2) {
                self.errorMessageLastNameLabel.isHidden = false
            }
        } else {
            errorMessageLastNameLabel.isHidden = true
        }
        
        if firstNameTextField.text == ""{
            error = true
            UIView.animate(withDuration: 0.2) {
                self.errorMessageFirstNameLabel.isHidden = false
            }
        } else {
            errorMessageFirstNameLabel.isHidden = true
        }
        
        if profileTextField.text == ""{
            error = true
            UIView.animate(withDuration: 0.2) {
                self.errorMessageProfileLabel.isHidden = false
            }
        } else {
            errorMessageProfileLabel.isHidden = true
        }
        
        if !isValidMail(value: emailTextField.text ?? "") {
            error = true
            UIView.animate(withDuration: 0.2) {
                self.errorMessageEmailLabel.isHidden = false
            }
        } else {
            errorMessageEmailLabel.isHidden = true
        }
        
        if error == false {
            
            if let context = self.getContext() {
                let user = User(context: context)
                guard let profile = profileTextField.text as? String else { return }
                user.lastName = lastNameTextField.text
                user.firstName = firstNameTextField.text
                user.profile = profile.uppercased()
                user.email = emailTextField.text
                
                if let token = getToken() {
                    _ = APIClient.instance.updateUser(token: token, user: user, onSuccess: { (_) in
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }, onError: { (_) in
                        let alert = UIAlertController(title: "Erreur", message: "Utilisateur non modifié", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            }
            
        }
        
        UIView.animate(withDuration: -1, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            self.validateButton.backgroundColor = .green
            UIView.animate(withDuration: -1, animations: {
                self.validateButton.backgroundColor = .rosyBrown
            })
        }
        
    }
    
    func isValidMail(value: String) -> Bool {
        let mailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let mailTest = NSPredicate(format: "SELF MATCHES %@", mailRegex)
        let result = mailTest.evaluate(with: value)
        return result
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == pickerTextField {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear(_:)), name:UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardDisappear(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    // Don't forget to unregister when done
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func onKeyboardAppear(_ notification: NSNotification) {
        let info = notification.userInfo!
        let rect: CGRect = info[UIResponder.keyboardFrameBeginUserInfoKey] as! CGRect
        let kbSize = rect.size
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your application might not need or want this behavior.
        var aRect = self.view.frame
        aRect.size.height -= kbSize.height
        
        let activeField: UITextField? = [lastNameTextField, firstNameTextField, emailTextField].first { $0.isFirstResponder }
        if let activeField = activeField {
            if aRect.contains(activeField.frame.origin) {
                let scrollPoint = CGPoint(x: 0, y: activeField.frame.origin.y-kbSize.height)
                scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
    }
    
    @objc func onKeyboardDisappear(_ notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    func getContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
}
