//
//  SignUpViewController.swift
//  Laba1
//
//  Created by Dzmitry Mukhliada on 2/15/19.
//  Copyright © 2019 Dzmitry Mukhliada. All rights reserved.
//

import UIKit
import CryptoSwift

class SignUpViewController: UIViewController {

    @IBOutlet weak var LoginField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet weak var RepeatPasswordField: UITextField!
    @IBOutlet weak var NameField: UITextField!
    @IBOutlet weak var SurnameField: UITextField!
    @IBOutlet weak var PatronymicField: UITextField!
    @IBOutlet weak var LocationField: UITextField!
    @IBOutlet weak var GenderControl: UISegmentedControl!
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var PhotoView: UIImageView!
    @IBOutlet weak var BirthDateSwitcher: UISwitch!
    @IBOutlet weak var LoginLabel: UILabel!
    @IBOutlet weak var displayProgress: UIProgressView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var EditUser = false
    var UserEdit = Profile()
    
    var standartImage = true
    var imagePicker = UIImagePickerController()
    var alert = UIAlertController(title: "Warning", message: "message", preferredStyle: .alert)
    
    var Response = {
        (status: Bool?, error: Error?, controller: UIViewController, progress: Double?) in
            let vc = controller as! SignUpViewController
        
            if status == nil && error == nil {
                vc.displayProgress.progress = Float(progress!)
            }
        
            if status != nil {
                vc.displayProgress.isHidden = true
                if (status!) {
                    vc.navigationController?.popViewController(animated: true)
                } else {
                    vc.alert.message = "User with this login already exists!"
                    vc.present(vc.alert, animated: true, completion: nil)
                }
            }
        
            if error != nil {
                vc.displayProgress.isHidden = true
                print(error!)
            }
    }
    
    func SetEdit() {
        LoginLabel.isHidden = true
        LoginField.isHidden = true
        
        LoginField.text = UserEdit.LogIn
        NameField.text = UserEdit.Name
        SurnameField.text = UserEdit.Surname
        if UserEdit.Sex == "Woman" {
            GenderControl.selectedSegmentIndex = 1
        }
        
        LocationField.text = UserEdit.Place ?? ""
        PatronymicField.text = UserEdit.Patronymic ?? ""
        if let date = UserEdit.BirthDate {
            DatePicker.setDate(date, animated: true)
        } else {
            BirthDateSwitcher.isOn = false
            DatePicker.isHidden = true
        }
        
        if let photo = URL(string: UserEdit.PhotoLink!) {
            PhotoView.load(url: photo, indicator: loading)
            standartImage = false
        } else {
            SexChanged(self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if EditUser {
            SetEdit()
        }
    
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(imageSwiped))
        PhotoView.isUserInteractionEnabled = true
        swipe.direction = .up
        PhotoView.addGestureRecognizer(tap)
        PhotoView.addGestureRecognizer(swipe)
        PhotoView.layer.masksToBounds = true
        PhotoView.layer.cornerRadius = 5
        imagePicker.delegate = self
        
        DatePicker.layer.masksToBounds = true
        DatePicker.layer.borderWidth = 0.1
        DatePicker.layer.borderColor = LoginField.layer.borderColor
        DatePicker.layer.cornerRadius = 5
        DatePicker.layer.backgroundColor = UIColor.white.cgColor
    }
    
    func SignUp() {
        LoginField.text      = LoginField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        SurnameField.text    = SurnameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        NameField.text       = NameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        PatronymicField.text = PatronymicField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        LocationField.text   = LocationField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if PasswordField.text == RepeatPasswordField.text {
            if LoginField.text != "" && PasswordField.text != "" && NameField.text != "" && SurnameField.text != "" {
                let User = Profile()
                User.Name = NameField.text!
                User.Surname = SurnameField.text!
                User.LogIn = LoginField.text!
                User.Password = PasswordField.text!.sha256()
                
                User.Patronymic = PatronymicField.text
                User.BirthDate = BirthDateSwitcher.isOn ? DatePicker.date : nil
                User.Place = LocationField.text
                User.Sex = GenderControl.selectedSegmentIndex == 0 ? "Man" : "Woman"
                let photoData = PhotoView.image!.pngData()!
                
                if EditUser {
                    UserEdit.Name = NameField.text!
                    UserEdit.Surname = SurnameField.text!
                    UserEdit.Patronymic = PatronymicField.text!
                    UserEdit.Password = PasswordField.text!.sha256()
                    UserEdit.Place = LocationField.text!
                    UserEdit.Sex = GenderControl.selectedSegmentIndex == 0 ? "Man" : "Woman"
                    UserEdit.BirthDate = BirthDateSwitcher.isOn ? DatePicker.date : nil
                    
                    UsersController.sharedInstance.UpdateUser_firebase(updUser: UserEdit, photo: photoData, controller: self, closure: Response)
                } else {
                    UsersController.sharedInstance.AddUser_firebase(newUser: User, photo: photoData, controller: self, closure: Response)
                }
            } else {
                alert.message = "Fields with * should be filled!"
                present(alert, animated: true, completion: nil)
            }
        } else {
            alert.message = "Passwords are not coincide!"
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func SexChanged(_ sender: Any) {
        if standartImage {
            if GenderControl.selectedSegmentIndex == 0 {
                UIView.transition(with: PhotoView,
                                  duration: 0.75,
                                  options: .transitionCrossDissolve,
                                  animations: { self.PhotoView.image = UIImage(named: "placeholder_m") },
                                  completion: nil)
            } else {
                UIView.transition(with: PhotoView,
                                  duration: 0.75,
                                  options: .transitionCrossDissolve,
                                  animations: { self.PhotoView.image = UIImage(named: "placeholder_f") },
                                  completion: nil)
            }
        }
    }
    
    @IBAction func Save(_ sender: Any) {
        if displayProgress.isHidden {
            displayProgress.isHidden = false
        }
        
        SignUp()
    }
    
    @IBAction func enableBirthDate(_ sender: Any) {
        DatePicker.isHidden = !BirthDateSwitcher.isOn
    }
    
    @objc func imageTapped()
    {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func imageSwiped()
    {
        standartImage = true
        SexChanged(self)
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            UIView.transition(with: PhotoView,
                              duration: 0.75,
                              options: .transitionCrossDissolve,
                              animations: { self.PhotoView.image = selectedImage },
                              completion: nil)
            standartImage = false
        }
        
        dismiss(animated: true, completion: nil)
    }
}
