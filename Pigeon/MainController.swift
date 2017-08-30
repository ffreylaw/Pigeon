//
//  MainController.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 11/8/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class MainController: UITabBarController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        // Setup tab bar
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
        
        // Singleton
        let loginVC = LoginViewController.sharedInstance
        loginVC.delegates = [MainDataDelegate]()
        
        // Home
        let homeVC = HomeViewController()
        // homeVC is one of the delegates for loginVC. It performs reloading data on itself
        loginVC.delegates?.append(homeVC)
        // homeVC has a navigation
        let homeNC = UINavigationController(rootViewController: homeVC)
        // tabBarItem is accessible from homeNC because homeNC is created in UITabBarController
        homeNC.tabBarItem.title = "Home"
        
        // Chats
        let chatsVC = ChatsViewController()
	    loginVC.delegates?.append(chatsVC)
        let chatsNC = UINavigationController(rootViewController: chatsVC)
        chatsNC.tabBarItem.title = "Chats"
        
        // Contacts
        let contactsVC = ContactsViewController()
        loginVC.delegates?.append(contactsVC)
        let contactsNC = UINavigationController(rootViewController: contactsVC)
        contactsNC.tabBarItem.title = "Contacts"
        
        // Me
        let meVC = MeViewController()
        loginVC.delegates?.append(meVC)
        let meNC = UINavigationController(rootViewController: meVC)
        meNC.tabBarItem.title = "Me"
        
        // Add all navigations
        viewControllers = [homeNC, chatsNC, contactsNC, meNC]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

