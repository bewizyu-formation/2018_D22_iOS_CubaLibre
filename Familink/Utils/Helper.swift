//
//  Helper.swift
//  Familink
//
//  Created by formation 1 on 29/01/2019.
//  Copyright © 2019 CubaLibre. All rights reserved.
//

import Foundation
import UIKit
import CoreData

func getToken() -> String? {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return nil
    }
    let context = appDelegate.persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<Token> = Token.fetchRequest()
    if let result = try? context.fetch(fetchRequest) {
        
        if (!result.isEmpty) {
            
            // Il ne doit y avoir qu'un seul JWT en base de données
            guard let token = result[0].value else { return nil }
            return token
        }
        return nil
    }
    return nil
}
