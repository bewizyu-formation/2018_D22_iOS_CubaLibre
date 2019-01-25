//
//  ViewController.swift
//  Familink
//
//  Created by formation9 on 23/01/2019.
//  Copyright © 2019 CubaLibre. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let didUserConnect = Notification.Name("didUserConnect")
}

class ViewController: UIViewController {


    @IBOutlet weak var LoginContainerView: UIView!
    @IBOutlet weak var ContactListContainerView: UIView!
    
    var isConnected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didUserConnect, object: nil)
    }
    
    @objc func onDidReceiveData(_ notification:Notification) {
        isConnected = true
        toggleUINavigation()
    }
    
    func toggleUINavigation() {
        if (isConnected) {
            LoginContainerView.alpha = 0
            ContactListContainerView.alpha = 1
        }
        else {
            LoginContainerView.alpha = 1
            ContactListContainerView.alpha = 0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        toggleUINavigation()
    }
}

