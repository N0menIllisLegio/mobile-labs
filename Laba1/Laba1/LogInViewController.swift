//
//  LogInViewController.swift
//  Laba1
//
//  Created by Dzmitry Mukhliada on 2/15/19.
//  Copyright © 2019 Dzmitry Mukhliada. All rights reserved.
//

import UIKit
import CryptoSwift

class LogInViewController: UIViewController {
    
    @IBOutlet weak var LogInField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    
    @IBOutlet weak var LogInButton: UIButton!
    @IBOutlet weak var SignUpButton: UIButton!
    
    var alert = UIAlertController(title: "Warning", message: "message", preferredStyle: .alert)
    var LoggedUser: Profile?
    
    func ConfigureButtons() {
        LogInButton.layer.borderColor = UIColor.black.cgColor
        LogInButton.layer.borderWidth = 0.1
        LogInButton.layer.cornerRadius = 5
        
        SignUpButton.layer.borderColor = UIColor.black.cgColor
        SignUpButton.layer.borderWidth = 0.1
        SignUpButton.layer.cornerRadius = 5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        ConfigureButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        LogInField.text = ""
        PasswordField.text = ""
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func LogIn(_ sender: Any) {
        let enteredLogIn = LogInField.text
        let enteredPassword = PasswordField.text
        
        LoggedUser = UsersController.sharedInstance.GetUser(login: enteredLogIn!)
        if LoggedUser?.Password == enteredPassword!.sha256() {
            performSegue(withIdentifier: "logIn", sender: self)
        } else {
            LoggedUser = nil
            alert.message = "LogIn or Password dont match!"
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == "logIn" {
            let destination = segue.destination as? UsersListViewController
            destination?.CurrentUser = LoggedUser
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
