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
    
    @objc func goToSegue() {
        performSegue(withIdentifier: "editUser", sender: self)
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
        
        if AddEditBarButton != nil && AddEditBarButton! {
            self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(goToSegue)), animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if  UserInfo != nil {
            ReLoadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editUser", let dest = segue.destination as? SignUpViewController {
            dest.EditUser = true
            dest.UserEdit = UserInfo!
        }
    }
}
