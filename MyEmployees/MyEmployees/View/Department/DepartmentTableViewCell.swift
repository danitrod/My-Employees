//
//  DepartmentTableViewCell.swift
//  MyEmployees
//
//  Created by Daniel Rodrigues on 21/10/18.
//  Copyright © 2018 danitrod. All rights reserved.
//

import UIKit

class DepartmentTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
