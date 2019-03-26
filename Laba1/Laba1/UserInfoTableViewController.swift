//
//  UserInfoTableViewController.swift
//  Laba1
//
//  Created by Dzmitry Mukhliada on 3/24/19.
//  Copyright © 2019 Dzmitry Mukhliada. All rights reserved.
//

import UIKit

class UserInfoTableViewController: UITableViewController {
    
    @IBOutlet weak var Surname: UILabel!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Patronymic: UILabel!
    @IBOutlet weak var Sex: UILabel!
    @IBOutlet weak var Location: UILabel!
    @IBOutlet weak var BirthDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadData(UserInfo: Profile) {
        Surname.text = UserInfo.Surname
        Name.text = UserInfo.Name
        Sex.text = UserInfo.Sex
        
        print("Patronimic " + (UserInfo.Patronymic ?? "-"))
        Patronymic.text = UserInfo.Patronymic ?? "-"
        Location.text = UserInfo.Place ?? "-"
        
        if UserInfo.BirthDate != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            BirthDate.text = dateFormatter.string(from: UserInfo.BirthDate!)
        } else {
            BirthDate.text = "-"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}
