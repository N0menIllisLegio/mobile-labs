//
//  Profile.swift
//  Laba1
//
//  Created by Dzmitry Mukhliada on 2/15/19.
//  Copyright © 2019 Dzmitry Mukhliada. All rights reserved.
//

import UIKit

class Profile: NSObject {
    var LogIn: String = ""
    var Password: String = ""
    var Name: String = ""
    var Surname: String = ""
    var Sex: String = ""
    
    var Patronymic: String? = nil
    var BirthDate: Date? = nil
    var Place: String? = nil
    var PhotoLink: String? = nil
    var DeleteHash: String? = nil
}
