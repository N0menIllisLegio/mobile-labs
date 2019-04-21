//
//  UserTableViewCell.swift
//  Laba1
//
//  Created by Dzmitry Mukhliada on 3/23/19.
//  Copyright © 2019 Dzmitry Mukhliada. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var UsersPhoto: UIImageView!
    @IBOutlet weak var UsersName: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
