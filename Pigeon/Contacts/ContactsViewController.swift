//
//  ContactsViewController.swift
//  Pigeon
//
//  Created by Meng Yuan on 27/8/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isTranslucent = false
        
        view.backgroundColor = .groupTableViewBackground
    }

}


// MARK: - LoginViewControllerDelegate
// ContactsViewController is a delegate for LoginViewController. 
// It provides the functionality of cleaning and reloading data in the HomeViewController itself.
extension ContactsViewController: LoginViewControllerDelegate {
    func reloadData() {
        //...
    }
}
