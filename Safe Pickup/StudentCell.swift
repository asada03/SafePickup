//
//  StudentCellTableViewCell.swift
//  Safe Pickup
//
//  Created by Andres Luis Sada Govela on 28/07/18.
//  Copyright © 2018 Andres Luis Sada Govela. All rights reserved.
//

import UIKit

class StudentCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var classroomLabel: UILabel!
    
    var willPickup = true {
        didSet {
            if willPickup {
                containerView.layer.borderColor = UIColor.black.cgColor
                nameLabel.textColor = .black
                lastNameLabel.textColor = .black
                classroomLabel.alpha = 1.0
            }
            else {
                containerView.layer.borderColor = UIColor.lightGray.cgColor
                nameLabel.textColor = .lightGray
                lastNameLabel.textColor = .lightGray
                classroomLabel.alpha = 0.3
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.layer.borderWidth = 2
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
