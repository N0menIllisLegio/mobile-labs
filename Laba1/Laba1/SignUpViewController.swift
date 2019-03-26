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
    
    var EditUser = false
    var UserEdit = Profile()
    
    var standartImage = true
    var imagePicker = UIImagePickerController()
    var alert = UIAlertController(title: "Warning", message: "message", preferredStyle: .alert)
    
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
        
        if let photo = UserEdit.PhotoData {
            PhotoView.image = UIImage(data: photo)
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
    
    func SignUp() -> Bool {
        var signedUp = false
        
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
                
                User.Patronymic = PatronymicField.text == "" ? nil : PatronymicField.text
                User.BirthDate = BirthDateSwitcher.isOn ? DatePicker.date : nil
                User.Place = LocationField.text == "" ? nil : LocationField.text
                User.Sex = GenderControl.selectedSegmentIndex == 0 ? "Man" : "Woman"
                User.PhotoData = PhotoView.image?.pngData()
                
                if EditUser {
                    signedUp = UsersController.sharedInstance.UpdateUser(User: User)
                } else {
                    signedUp = UsersController.sharedInstance.AddUser(User: User)
                    if !signedUp {
                        alert.message = "User with this login already exists!"
                        present(alert, animated: true, completion: nil)
                    }
                }
                
            } else {
                alert.message = "Fields with * should be filled!"
                present(alert, animated: true, completion: nil)
            }
        } else {
            alert.message = "Passwords are not coincide!"
            present(alert, animated: true, completion: nil)
        }
        
        return signedUp
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
        if SignUp() {
            navigationController?.popViewController(animated: true)
        }
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
