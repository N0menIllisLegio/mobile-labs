//
//  UsersDetailsViewController.swift
//  Laba1
//
//  Created by Dzmitry Mukhliada on 3/23/19.
//  Copyright © 2019 Dzmitry Mukhliada. All rights reserved.
//

import UIKit

class UsersDetailsViewController: UIViewController {
    
    @IBOutlet weak var Photo: UIImageView!
    @IBOutlet weak var displayProgress: UIProgressView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var UserInfo: Profile?
    var AddEditBarButton: Bool?
    var UsersIndexPath: IndexPath?
    
    @objc func goToSegue() {
        performSegue(withIdentifier: "editUser", sender: self)
    }
    
    @objc func deleteUser() {
        if splitViewController?.viewControllers.count ?? 1 > 1 {
            let vc = (splitViewController?.viewControllers[0] as? UINavigationController)?.topViewController as? UsersListViewController
            vc?.deleteUser(_indexPath: UsersIndexPath)
        } else {
            performSegue(withIdentifier: "deleteUser", sender: self)
//            let vc = children[0] as? UsersListViewController
//            vc?.deleteUser(_indexPath: UsersIndexPath)
        }
    }
    
    func ReLoadData() {
        if let photo = URL(string: UserInfo!.PhotoLink!) {
            Photo.load(url: photo, indicator: loading)
            Photo.layer.masksToBounds = true
            Photo.layer.cornerRadius = 5
        } else {
            if  UserInfo?.Sex == "Man" {
                Photo.image = UIImage(named: "placeholder_m")
            } else {
                Photo.image = UIImage(named: "placeholder_f")
            }
        }
        
        let staticTable = self.children[0] as! UserInfoTableViewController
        staticTable.loadData(UserInfo: UserInfo!)
    }
    
    override func viewDidLoad() {        
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        self.navigationItem.leftItemsSupplementBackButton = true
        
        if AddEditBarButton != nil && AddEditBarButton! {
            self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(goToSegue)), animated: true)
        } else {
            self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteUser)), animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if  UserInfo != nil {
            ReLoadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editUser", let dest = (segue.destination as? UINavigationController)?.topViewController as? SignUpViewController {
            dest.EditUser = true
            dest.UserEdit = UserInfo!
        }
        
        if segue.identifier == "addUser", let dest = (segue.destination as? UINavigationController)?.topViewController as? SignUpViewController {
            dest.EditUser = false
        }
        
        if segue.identifier == "deleteUser", let dest = segue.destination as? UsersListViewController {
            dest.delUserPath = UsersIndexPath
        }
    }
}
