//
//  Profile.swift
//  Laba1
//
//  Created by Dzmitry Mukhliada on 2/15/19.
//  Copyright © 2019 Dzmitry Mukhliada. All rights reserved.
//

import UIKit
import RealmSwift

class Profile: Object {
    
    @objc dynamic var LogIn: String = ""
    @objc dynamic var Password: String = ""
    @objc dynamic var Name: String = ""
    @objc dynamic var Surname: String = ""
    @objc dynamic var Sex: String = ""
    
    @objc dynamic var Patronymic: String? = nil
    @objc dynamic var BirthDate: Date? = nil
    @objc dynamic var Place: String? = nil
    @objc dynamic var PhotoData: Data? = nil
    
    override static func primaryKey() -> String? {
        return "LogIn"
    }
}
