//
//  UserDetailsViewController.swift
//  Familink
//
//  Created by formation 1 on 25/01/2019.
//  Copyright © 2019 CubaLibre. All rights reserved.
//

import UIKit

class UserDetailsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onEditButtonPressed(_ sender: Any) {
        let editUserController = EditUserViewController(nibName:nil, bundle: nil)
        self.navigationController?.pushViewController(editUserController, animated: true)
    }
    
    @IBAction func onDisconnectButtonPressed(_ sender: Any) {
        NotificationCenter.default.post(name: .didUserDisconnect, object: nil)
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
