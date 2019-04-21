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
    
    @IBOutlet weak var displayProgress: UIProgressView!
    
    var alert = UIAlertController(title: "Warning", message: "message", preferredStyle: .alert)
    var LoggedUser: Profile?
    
    var validateUser = {
        (user: Profile?, error: Error?, controller: UIViewController, progress: Double?) in
            let vc = (controller as! LogInViewController)
        
            if user == nil && error == nil {
                vc.displayProgress.progress = Float(progress!)
            }
        
            if user != nil {
                vc.displayProgress.isHidden = true
                if user!.Password == vc.PasswordField.text!.sha256() {
                    vc.LoggedUser = user!
                    vc.performSegue(withIdentifier: "logIn", sender: vc)
                } else {
                    vc.LoggedUser = nil
                    vc.alert.message = "LogIn or Password dont match!"
                    vc.present(vc.alert, animated: true, completion: nil)
                }
            }
            if error != nil {
                vc.displayProgress.isHidden = true
                print(error!)
            }
    }

    func ConfigureButtons() {
        LogInButton.layer.borderColor = UIColor.black.cgColor
        LogInButton.layer.borderWidth = 0.1
        LogInButton.layer.cornerRadius = 5
        SignUpButton.layer.borderColor = UIColor.black.cgColor
        SignUpButton.layer.borderWidth = 0.1
        SignUpButton.layer.cornerRadius = 5
        
//        let User = Profile()
//        User.LogIn = "Gadfly"
//        User.DeleteHash = "VTSl35q9CmhGPde"
//
//        UsersController.sharedInstance.DeleteUser_firebase(User: User)
//        print(UIImage(named: "placeholder_m")!.pngData()!.base64EncodedString())
//        UsersController.sharedInstance.UploadPhoto(data: UIImage(named: "placeholder_f")!.pngData()!)
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
        if displayProgress.isHidden {
            displayProgress.isHidden = false
        }
        
        UsersController.sharedInstance.GetUser_firebase(id: LogInField.text!, controller: self, closure: validateUser)
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
