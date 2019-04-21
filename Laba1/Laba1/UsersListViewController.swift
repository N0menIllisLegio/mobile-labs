//
//  UsersListViewController.swift
//  Laba1
//
//  Created by Dzmitry Mukhliada on 3/23/19.
//  Copyright © 2019 Dzmitry Mukhliada. All rights reserved.
//

import UIKit

class UsersListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var CurrentUserBcView: UIView!
    @IBOutlet weak var CurrentUserPhoto: UIImageView!
    @IBOutlet weak var CurrentUserSurname: UILabel!
    @IBOutlet weak var CurrentUserName: UILabel!
    @IBOutlet weak var CurrentUserPatronymic: UILabel!
    @IBOutlet weak var CurrentUserSex: UILabel!
    @IBOutlet weak var PatronymicStack: UIStackView!
    @IBOutlet weak var displayProgress: UIProgressView!
    @IBOutlet weak var loadImageCurrentUser: UIActivityIndicatorView!
    
    var CurrentUser: Profile?

    @IBOutlet weak var UsersTable: UITableView!
    
    var Users = [Profile]()
    
    let LoadData = {
        (users: [Profile]?, error: Error?, controller: UIViewController, progress: Double?) in
        let vc = controller as! UsersListViewController
        
        if users == nil && error == nil {
            vc.displayProgress.progress = Float(progress!)
        }
        
        if let allUsers = users {
            vc.Users = allUsers.filter { $0.LogIn != vc.CurrentUser!.LogIn }
            vc.UsersTable.reloadData()
            vc.displayProgress.isHidden = true
        }
        if error != nil {
            vc.displayProgress.isHidden = true
            print(error!)
        }
    }
    
    func ConfigureCurrentUser() {
        CurrentUserBcView.layer.masksToBounds = false
        CurrentUserBcView.layer.shadowColor = UsersTable.separatorColor?.cgColor
        CurrentUserBcView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        CurrentUserBcView.layer.shadowOpacity = 1.0
        CurrentUserBcView.layer.shadowRadius = 0.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ConfigureCurrentUser()
        UsersTable.delegate = self
        UsersTable.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if displayProgress.isHidden {
            displayProgress.isHidden = false
        }
        
        if CurrentUser != nil {
            if let User = CurrentUser {
                CurrentUserSurname.text = User.Surname
                CurrentUserName.text = User.Name
                CurrentUserSex.text = User.Sex
                
                if CurrentUser!.Patronymic != "" {
                    PatronymicStack.isHidden = false
                    CurrentUserPatronymic.text = CurrentUser!.Patronymic
                } else {
                    PatronymicStack.isHidden = true
                }
                
                if let photo = URL(string: CurrentUser!.PhotoLink!) {
                    CurrentUserPhoto.load(url: photo, indicator: loadImageCurrentUser)
                    CurrentUserPhoto.layer.masksToBounds = true
                    CurrentUserPhoto.layer.cornerRadius = 5
                }  else {
                    if  User.Sex == "Man" {
                        CurrentUserPhoto.image = UIImage(named: "placeholder_m")
                    } else {
                        CurrentUserPhoto.image = UIImage(named: "placeholder_f")
                    }
                }
            }
            
            UsersController.sharedInstance.GetAllUsers_firebase(controller: self, closure: LoadData)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "currentUserDetails", let destination = segue.destination as? UsersDetailsViewController {
            
            destination.UserInfo = CurrentUser
            destination.AddEditBarButton = true
        }
        
        if segue.identifier == "tableUserDetails", let destination = segue.destination as? UsersDetailsViewController {

            destination.AddEditBarButton = false
            destination.UserInfo = Users[UsersTable.indexPathForSelectedRow!.row]
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as? UserTableViewCell  else {
            fatalError("The dequeued cell is not an instance of UserTableViewCell.")
        }
        let user = Users[indexPath.row]
        
        cell.UsersName!.text = user.Name + " " + user.Surname
        
        if let photo = URL(string: user.PhotoLink!) {
            cell.UsersPhoto!.load(url: photo, indicator: cell.loading)
            cell.UsersPhoto!.layer.masksToBounds = true
            cell.UsersPhoto!.layer.cornerRadius = 5
        } else {
            if  user.Sex == "Man" {
                cell.UsersPhoto!.image = UIImage(named: "placeholder_m")
            } else {
                cell.UsersPhoto!.image = UIImage(named: "placeholder_f")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let DeleteAlert = UIAlertController(title: "Delete", message: "All data of this user will be lost.", preferredStyle: UIAlertController.Style.alert)
            
            DeleteAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                UsersController.sharedInstance.DeleteUser_firebase(User: self.Users[indexPath.row])
                self.Users.remove(at: indexPath.row)
                self.UsersTable.deleteRows(at: [indexPath], with: .automatic)
            }))
            
            DeleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in return }))
            
            present(DeleteAlert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "ALL USERS"
    }
}
