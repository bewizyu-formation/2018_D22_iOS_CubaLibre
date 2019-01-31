//
//  SignUpViewController.swift
//  Familink
//
//  Created by formation 1 on 24/01/2019.
//  Copyright © 2019 CubaLibre. All rights reserved.
//

import UIKit
import MessageUI
import CoreData


class SignUpViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {


    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var profileTextField: UITextField!
    @IBOutlet weak var pickerTextField: UITextField!
    @IBOutlet weak var mailTextField: UITextField!
    
    @IBOutlet weak var errorMessagePhoneLabel: UILabel!
    @IBOutlet weak var errorMessageNameLabel: UILabel!
    @IBOutlet weak var errorMessageFirstnameLabel: UILabel!
    @IBOutlet weak var errorMessagePasswordLabel: UILabel!
    @IBOutlet weak var errorMessageProfileLabel: UILabel!
    @IBOutlet weak var errorMessageMailLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var pickOption = ["Famille", "Senior", "Medecin"]
    
    var user : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pickerView = UIPickerView()
        self.hideKeyboardGesture()
        pickerView.delegate = self
        pickerTextField.inputView = pickerView
        
        errorMessagePhoneLabel.isHidden = true
        errorMessageNameLabel.isHidden = true
        errorMessageFirstnameLabel.isHidden = true
        errorMessagePasswordLabel.isHidden = true
        errorMessageProfileLabel.isHidden = true
        errorMessageMailLabel.isHidden = true
        
        pickerTextField.delegate = self
        
        phoneTextField.delegate = self
        nameTextField.delegate = self
        firstnameTextField.delegate = self
        passwordTextField.delegate = self
        mailTextField.delegate = self
        
        registerForKeyboardNotifications()
    }
    
    @IBAction func SignUpAndConnect(_ sender: Any) {
        
        var error = false
        
        if !isValidPhone(value: phoneTextField.text ?? "") {
            error = true
            UIView.animate(withDuration: 0.2) {
                self.errorMessagePhoneLabel.isHidden = false
                
            }
        } else {
            errorMessagePhoneLabel.isHidden = true
        }
        
        if nameTextField.text == ""{
            error = true
            UIView.animate(withDuration: 0.2) {
                self.errorMessageNameLabel.isHidden = false
                
            }
        } else {
            errorMessageNameLabel.isHidden = true
        }
        
        if firstnameTextField.text == ""{
            error = true
            UIView.animate(withDuration: 0.2) {
                self.errorMessageFirstnameLabel.isHidden = false
                
            }
        } else {
            errorMessageFirstnameLabel.isHidden = true
        }
        
        if !isValidPassword(value: passwordTextField.text ?? "") {
            error = true
            UIView.animate(withDuration: 0.2) {
                self.errorMessagePasswordLabel.isHidden = false}
        } else {
            errorMessagePasswordLabel.isHidden = true
        }
        
        if profileTextField.text == ""{
            error = true
            UIView.animate(withDuration: 0.2) {
                self.errorMessageProfileLabel.isHidden = false}
        } else {
            errorMessageProfileLabel.isHidden = true
        }
        
        if !isValidMail(value: mailTextField.text ?? "") {
            error = true
            UIView.animate(withDuration: 0.2) {
                self.errorMessageMailLabel.isHidden = false}
        } else {
            errorMessageMailLabel.isHidden = true
        }
        
        if error == false {
        
            if let context = getContext() {
                let user = User(context: context)
                
                guard let password = passwordTextField.text else { return }
                
                guard let profile = profileTextField.text as? String else { return }
                user.phone = phoneTextField.text
                user.lastName = nameTextField.text
                user.profile = profile.uppercased()
                user.firstName = firstnameTextField.text
                user.email = mailTextField.text
                
                APIClient.instance.addUser(user: user, password: password, onSuccess: onAddUserSuccess, onError: onAddUserError)
            }
        }
    }
    
    func getContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    func onAddUserSuccess (user: User, password : String) {
        DispatchQueue.main.async {
            
            _ = APIClient.instance.getToken(login: user.phone ?? "", password: password, onSuccess: { (token : String) in
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                    //NotificationCenter.default.post(name: .didUserConnect, object: nil)
                }
            }, onError: { (errorMessage : String) in
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Erreur", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
            
        }
    }
    
    func onAddUserError (message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Erreur", message: "Utilisateur non ajouté", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
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
    
    func isValidPhone(value: String) -> Bool {
        let phoneRegex = "^(0[67])(?:[ _.-]?([0-9]{2})){4}"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    func isValidPassword(value: String) -> Bool {
        let passwordRegex = "^([0-9]){4}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        let result = passwordTest.evaluate(with: value)
        return result
    }
    
    func isValidMail(value: String) -> Bool {
        let mailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let mailTest = NSPredicate(format: "SELF MATCHES %@", mailRegex)
        let result = mailTest.evaluate(with: value)
        return result
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
        
        let activeField: UITextField? = [nameTextField, firstnameTextField, phoneTextField, passwordTextField, mailTextField].first { $0.isFirstResponder }
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
}
