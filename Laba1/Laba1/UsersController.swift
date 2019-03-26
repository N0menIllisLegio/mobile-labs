//
//  UsersController.swift
//  Laba1
//
//  Created by Dzmitry Mukhliada on 3/24/19.
//  Copyright © 2019 Dzmitry Mukhliada. All rights reserved.
//

import UIKit
import RealmSwift

class UsersController: NSObject {
    
    let realm: Realm
    static let sharedInstance = UsersController()
    
    func DeleteUser(User: Profile) {
        try! realm.write {
            realm.delete(User)
        }
    }
    
    func UpdateUser(User: Profile) -> Bool {
        var status = true
        
        do {
            try realm.write {
                realm.add(User, update: true)
            }
        } catch {
            print("Update failed")
            status = false
        }
        
        return status
    }
    
    func AddUser(User: Profile) -> Bool {
        var status = true
        
        if let _ = realm.object(ofType: Profile.self, forPrimaryKey: User.LogIn) {
            status = false
        } else {
            do {
                try realm.write {
                    realm.add(User)
                }
            } catch {
                print("Adding failed")
                status = false
            }
        }
        
        return status
    }
    
    func GetAllUsers() -> Results<Profile> {
        let results = realm.objects(Profile.self)
        return results
    }
    
    private override init() {
        realm = try! Realm()
    }
    
    func GetUser(login: String) -> Profile? {
        let user = realm.object(ofType: Profile.self, forPrimaryKey: login)
        return user
    }
}
