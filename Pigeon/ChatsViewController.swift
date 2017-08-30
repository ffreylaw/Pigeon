//
//  ChatsViewController.swift
//  Pigeon
//
//  Created by Meng Yuan on 27/8/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class ChatsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}

// MARK: - MainDataDelegate
// ChatsViewController is a delegate for LoginViewController. 
// It provides the functionality of cleaning and reloading data in the HomeViewController itself.
extension ChatsViewController: LoginViewControllerDelegate {
    func reloadData() {
        //...
    }
}
