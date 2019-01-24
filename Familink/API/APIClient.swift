//
//  APIClient.swift
//  Familink
//
//  Created by formation9 on 24/01/2019.
//  Copyright © 2019 CubaLibre. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class APIClient {
    static let instance = APIClient()
    private let BASE_URL = "https://familink-api.cleverapps.io/"
    private let LOGIN_URI = "public/login/"
    private let ADD_USER_URI = "public/sign-in/"
    private let UPDATE_USER = "secured/users"
    private let CONTACT_URI = "secured/users/contacts/"
    private let TOKEN = "token"
    private let PHONE = "phone"
    private let PASSWORD = "password"
    private let FIRSTNAME = "firstName"
    private let LASTNAME = "lastName"
    private let EMAIL = "email"
    private let PROFILE = "profile"
    private let GRAVATAR = "gravatar"
    private let IS_FAMILINK_USER = "isFamilinkUser"
    private let IS_EMERGENCY_USER = "isEmergencyUser"
    private let CONTACT_ID = "_id"
    
    private init() {
    }
    
    func getToken(login : String, password : String, onSuccess: @escaping (String) -> (), onError: @escaping (String) -> ()) -> URLSessionTask {
        let json : [String: Any] = [self.PHONE : login, self.PASSWORD : password]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        var request = URLRequest(url: URL(string: "\(BASE_URL)\(LOGIN_URI)")! )
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if(httpResponse.statusCode != 200){
                    onError(self.getStatusError(statusCode: httpResponse.statusCode))
                } else {
                    if let dataResponse = data {
                        if let jsonResponse = try? JSONSerialization.jsonObject(with: dataResponse, options: [])  as! [String: String] {
                            let token = jsonResponse["token"] ?? ""
                            onSuccess(token)
                        }
                    } else {
                        onError("Erreur")
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
    
    func getContactList(token : String, onSuccess: @escaping ([Contact]) -> (), onError: @escaping (String) -> ()) -> URLSessionTask {
        var request = URLRequest(url: URL(string: "\(BASE_URL)\(CONTACT_URI)")! )
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer: \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if(httpResponse.statusCode != 200){
                    onError(self.getStatusError(statusCode: httpResponse.statusCode))
                } else {
                    if let dataResponse = data {
                        if let jsonResponse = try? JSONSerialization.jsonObject(with: dataResponse, options: [])  as! [Any] {
                            var contactsToReturn = [Contact]()
                            
                            for object in jsonResponse {
                                let objectDictionary = object as! [String:Any]
                                
                                let c = Contact(context: self.getContext()!)
                                c.contactId = objectDictionary[self.CONTACT_ID] as? String
                                c.firstName = objectDictionary[self.FIRSTNAME] as? String
                                c.lastName = objectDictionary[self.LASTNAME] as? String ?? ""
                                c.phone = objectDictionary[self.PHONE] as? String
                                c.email = objectDictionary[self.EMAIL] as? String
                                c.gravatar = objectDictionary[self.GRAVATAR] as? String ?? ""
                                c.profile = objectDictionary[self.PROFILE] as? String ?? ""
                                c.isFamilinkUser = objectDictionary[self.IS_FAMILINK_USER] as! Bool ?? false
                                c.isEmergencyUser = objectDictionary[self.IS_EMERGENCY_USER] as! Bool ?? false
                                
                                contactsToReturn.append(c)
                            }
                            onSuccess(contactsToReturn)
                        }
                    } else {
                        onError("Erreur")
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
    
    func addContact(token : String, contact : Contact, onSuccess: @escaping (String) -> (), onError: @escaping (String) -> ()) -> URLSessionTask {
        let jsonData = createJsonDataFromContact(contactToParseInJson : contact)
        
        var request = URLRequest(url: URL(string: "\(BASE_URL)\(CONTACT_URI)")! )
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer: \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if(httpResponse.statusCode != 200){
                    onError(self.getStatusError(statusCode: httpResponse.statusCode))
                } else {
                    onSuccess("Contact ajouté")
                }
            }
        }
        task.resume()
        
        return task
    }
    
    func updateContact(token : String, contact : Contact, onSuccess: @escaping (String) -> (), onError: @escaping (String) -> ()) -> URLSessionTask {
        let jsonData = createJsonDataFromContact(contactToParseInJson : contact)
        
        print(contact)
        
        var request = URLRequest(url: URL(string: "\(BASE_URL)\(CONTACT_URI)\(contact.contactId!)")! )
        request.httpMethod = "PUT"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer: \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if(httpResponse.statusCode != 204){
                    onError(self.getStatusError(statusCode: httpResponse.statusCode))
                } else {
                    onSuccess("Contact modifié")
                }
            }
        }
        task.resume()
        
        return task
    }
    
    func deleteContact(token : String, contactId : String, onSuccess: @escaping (String) -> (), onError: @escaping (String) -> ()) -> URLSessionTask {
        var request = URLRequest(url: URL(string: "\(BASE_URL)\(CONTACT_URI)\(contactId)")! )
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer: \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if(httpResponse.statusCode != 204){
                    onError(self.getStatusError(statusCode: httpResponse.statusCode))
                } else {
                    onSuccess("Contact supprimé")
                }
            }
        }
        task.resume()
        
        return task
    }
    
    func addUser(user : User, password : String, onSuccess: @escaping (String) -> (), onError: @escaping (String) -> ()) -> URLSessionTask {
        let jsonData = createJsonDataFromUser(userToParseInJson: user, password: password)
        
        var request = URLRequest(url: URL(string: "\(BASE_URL)\(ADD_USER_URI)")! )
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if(httpResponse.statusCode != 200){
                    onError(self.getStatusError(statusCode: httpResponse.statusCode))
                } else {
                    onSuccess("User ajouté")
                }
            }
        }
        task.resume()
        
        return task
    }
    
    func updateUser(token : String, user : User, onSuccess: @escaping (String) -> (), onError: @escaping (String) -> ()) -> URLSessionTask {
        let json : [String: Any] = [self.FIRSTNAME : user.firstName ?? "",
                                    self.LASTNAME : user.lastName ?? "",
                                    self.EMAIL : user.email ?? "",
                                    self.PROFILE : user.profile]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        var request = URLRequest(url: URL(string: "\(BASE_URL)\(UPDATE_USER)")! )
        request.httpMethod = "PUT"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer: \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if(httpResponse.statusCode != 200){
                    onError(self.getStatusError(statusCode: httpResponse.statusCode))
                } else {
                    onSuccess("User modifié")
                }
            }
        }
        task.resume()
        
        return task
    }
    
    func createJsonDataFromContact(contactToParseInJson : Contact) -> Data? {
        let json : [String: Any] = [self.CONTACT_ID : contactToParseInJson.contactId ?? "",
                                    self.FIRSTNAME : contactToParseInJson.firstName ?? "",
                                    self.LASTNAME : contactToParseInJson.lastName ?? "",
                                    self.PHONE : contactToParseInJson.phone ?? "",
                                    self.EMAIL : contactToParseInJson.email ?? "",
                                    self.GRAVATAR : contactToParseInJson.gravatar ?? "",
                                    self.IS_FAMILINK_USER : contactToParseInJson.isFamilinkUser,
                                    self.IS_EMERGENCY_USER : contactToParseInJson.isEmergencyUser]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        return jsonData
    }
    
    func createJsonDataFromUser(userToParseInJson : User, password : String) -> Data? {
        let json : [String: Any] = [self.FIRSTNAME : userToParseInJson.firstName ?? "",
                                    self.LASTNAME : userToParseInJson.lastName ?? "",
                                    self.PHONE : userToParseInJson.phone ?? "",
                                    self.EMAIL : userToParseInJson.email ?? "",
                                    self.PASSWORD : password ?? "",
                                    self.PROFILE : userToParseInJson.profile]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        return jsonData
    }
    
    func getStatusError(statusCode : Int) -> String {
        switch statusCode {
        case 400:
            return "Identifiant invalide"
        case 401:
            return "Session expirée"
        default:
            return "Serveur inaccessible"
        }
    }
    
    func getContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
}
