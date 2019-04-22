//
//  UsersController.swift
//  Laba1
//
//  Created by Dzmitry Mukhliada on 3/24/19.
//  Copyright © 2019 Dzmitry Mukhliada. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class UsersController: NSObject {
    let token = "YOUR IMGUR TOKEN"
    let firestore = "YOUR FIRESTORE PATH"
    let imgurAccountName = "YOUR IMGUR LOGIN"
    static let sharedInstance = UsersController()
        
    func DeletePhoto(deleteHash: String) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]
        
        Alamofire.request("https://api.imgur.com/3/account/" + imgurAccountName + "/image/" + deleteHash, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON {
                response in
                print(response)
        }
    }
    
    func UploadPhoto(data: Data, controller: UIViewController, closure: @escaping (String?, Error?, String?) -> Void, uploadProgress: @escaping (Bool?, Error?, UIViewController, Double?) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token,
            "Content-Type": "multipart/form-data"
        ]
        
        Alamofire.upload(data, to: "https://api.imgur.com/3/upload", method: .post, headers: headers)
            .uploadProgress{
                progress in
                uploadProgress(nil, nil, controller, progress.fractionCompleted)
            }
            .responseJSON {
                response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    closure(json["data"]["link"].stringValue, nil, json["data"]["deletehash"].stringValue)
                case .failure(let error):
                    closure(nil, error, nil)
                }
        }
    }
    
    func DeleteUser_firebase(User: Profile) {
        DeletePhoto(deleteHash: User.DeleteHash!)
        Alamofire.request(firestore + "/" + User.LogIn, method: .delete, parameters: nil)
            .responseJSON{ response in
                print(response)
        }
    }
    
    func UpdateUser_firebase(updUser: Profile, photo: Data, controller: UIViewController, closure: @escaping (Bool?, Error?, UIViewController, Double?) -> Void) {
        DeletePhoto(deleteHash: updUser.DeleteHash!)
        var birthDate : String
        
        if updUser.BirthDate == nil {
            birthDate = ""
        } else {
            birthDate = ISO8601DateFormatter().string(from: updUser.BirthDate!)
        }
        
        let uploadClosure = {
            (link: String?, error: Error?, deleteHash: String?) in
            if link != nil {
                Alamofire.request(self.firestore + "/" + updUser.LogIn + "?updateMask.fieldPaths=PhotoLink&updateMask.fieldPaths=DeleteHash", method: .patch, parameters: ["fields" : ["PhotoLink": ["stringValue": link!], "DeleteHash":["stringValue": deleteHash!]]], encoding: JSONEncoding.default, headers: nil )
                    .responseJSON
                    { response in
                        switch response.result {
                        case .success(let value):
                            let json = JSON(value)
                            if json["error"].exists() {
                                print(json["error"])
                                closure(false, nil, controller, nil)
                            } else {
                                updUser.PhotoLink = link!
                                updUser.DeleteHash = deleteHash
                                closure(true, nil, controller, nil)
                            }
                        case .failure(let error):
                            closure(nil, error, controller, nil)
                        }
                }
            } else {
                closure(nil, error, controller, nil)
            }
        }
        
        let fields: Parameters = [
            "fields" : [
                "LogIn":
                    ["stringValue": updUser.LogIn],
                "Name":
                    ["stringValue": updUser.Name],
                "Password":
                    ["stringValue": updUser.Password],
                "Surname":
                    ["stringValue": updUser.Surname],
                "Sex":
                    ["stringValue": updUser.Sex],
                "Patronymic":
                    ["stringValue": updUser.Patronymic!],
                "Place":
                    ["stringValue": updUser.Place!],
                "BirthDate":
                    ["stringValue": birthDate],
                "PhotoLink":
                    ["stringValue": ""],
                "DeleteHash":
                    ["stringValue": ""]
            ]
        ]
        
        // Можно конкретно задавать какие поля менять указывая: ?updateMask.fieldPaths=Name&updateMask.fieldPaths=Password&...
        Alamofire.request(firestore + "/" + updUser.LogIn, method: .patch, parameters: fields, encoding: JSONEncoding.default, headers: nil )
            .downloadProgress
            { progress in
                closure(nil, nil, controller, progress.fractionCompleted)
            }.responseJSON
            { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if json["error"].exists() {
                        print(json["error"])
                        closure(false, nil, controller, nil)
                    } else {
                        self.UploadPhoto(data: photo, controller: controller, closure: uploadClosure, uploadProgress: closure)
                    }
                case .failure(let error):
                    closure(nil, error, controller, nil)
                }
            }
    }
    
    func AddUser_firebase(newUser: Profile, photo: Data, controller: UIViewController, closure: @escaping (Bool?, Error?, UIViewController, Double?) -> Void) {
        var birthDate = ""
        
        if newUser.BirthDate != nil {
            birthDate = ISO8601DateFormatter().string(from: newUser.BirthDate!)
        }
        
        let uploadClosure = {
            (link: String?, error: Error?, deleteHash: String?) in
            if link != nil {
                Alamofire.request(self.firestore + "/" + newUser.LogIn + "?updateMask.fieldPaths=PhotoLink&updateMask.fieldPaths=DeleteHash", method: .patch, parameters: ["fields" : ["PhotoLink": ["stringValue": link!], "DeleteHash":["stringValue": deleteHash!]]], encoding: JSONEncoding.default, headers: nil )
                    .responseJSON
                    { response in
                        switch response.result {
                        case .success(let value):
                            let json = JSON(value)
                            if json["error"].exists() {
                                print(json["error"])
                                closure(false, nil, controller, nil)
                            } else {
                                closure(true, nil, controller, nil)
                            }
                        case .failure(let error):
                            closure(nil, error, controller, nil)
                        }
                    }
            } else {
                closure(nil, error, controller, nil)
            }
        }
        
        let fields: Parameters = [
            "fields" : [
                "LogIn":
                    ["stringValue": newUser.LogIn],
                "Name":
                    ["stringValue": newUser.Name],
                "Password":
                    ["stringValue": newUser.Password],
                "Surname":
                    ["stringValue": newUser.Surname],
                "Sex":
                    ["stringValue": newUser.Sex],
                "Patronymic":
                    ["stringValue": newUser.Patronymic!],
                "Place":
                    ["stringValue": newUser.Place!],
                "BirthDate":
                    ["stringValue": birthDate],
                "PhotoLink":
                    ["stringValue": ""],
                "DeleteHash":
                    ["stringValue": ""]
            ]
        ]
        
        Alamofire.request(firestore + "?documentId=" + newUser.LogIn, method: .post, parameters: fields, encoding: JSONEncoding.default, headers: nil )
            .downloadProgress
            { progress in
                closure(nil, nil, controller, progress.fractionCompleted)
            }.responseJSON
            { response in
                switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        if json["error"].exists() {
                            closure(false, nil, controller, nil)
                        } else {
                            self.UploadPhoto(data: photo, controller: controller, closure: uploadClosure, uploadProgress: closure)
                        }
                    case .failure(let error):
                        closure(nil, error, controller, nil)
                }
            }
    }
    
    private override init() { }
    
    func unpackFields(fields: JSON) -> Profile {
        let User = Profile()
        
        User.Name = fields["Name"]["stringValue"].stringValue
        User.Surname = fields["Surname"]["stringValue"].stringValue
        User.LogIn = fields["LogIn"]["stringValue"].stringValue
        User.Password = fields["Password"]["stringValue"].stringValue
        User.Patronymic = fields["Patronymic"]["stringValue"].string
        User.BirthDate = ISO8601DateFormatter().date(from: fields["BirthDate"]["stringValue"].stringValue)
        User.Place = fields["Place"]["stringValue"].string
        User.Sex = fields["Sex"]["stringValue"].stringValue
        User.PhotoLink = fields["PhotoLink"]["stringValue"].stringValue
        User.DeleteHash = fields["DeleteHash"]["stringValue"].stringValue
        
        return User
    }
    
    func GetUser_firebase(id: String, controller: UIViewController, closure: @escaping (Profile?, Error?, UIViewController, Double?) -> Void) {
        Alamofire.request(firestore + "/" + id)
            .downloadProgress
            { progress in
                closure(nil, nil, controller, progress.fractionCompleted)
            }.responseJSON
            { response in
                switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        let User = self.unpackFields(fields: json["fields"])
                        closure(User, nil, controller, nil)
                    case .failure(let error):
                        closure(nil, error, controller, nil)
                }
            }
    }
    
    func GetAllUsers_firebase(controller: UIViewController, closure: @escaping ([Profile]?, Error?, UIViewController, Double?) -> Void) {
        Alamofire.request(firestore)
            .downloadProgress
            { progress in
                closure(nil, nil, controller, progress.fractionCompleted)
            }.responseJSON
            { response in
                switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        let documents = json["documents"]
                        var Users = [Profile]()

                        for (_, document) in documents {
                            Users.append(self.unpackFields(fields: document["fields"]))
                        }
                        
                        closure(Users, nil, controller, nil)
                    case .failure(let error):
                        closure(nil, error, controller, nil)
                }
            }
    }
}

extension UIImageView {
    func load(url: URL, indicator: UIActivityIndicatorView) {
        indicator.isHidden = false
        self.isHidden = true
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        indicator.isHidden = true
                        self?.image = image
                        self?.isHidden = false
                    }
                }
            }
        }
    }
}
