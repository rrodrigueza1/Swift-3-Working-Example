//
//  CustomCell.swift
//  Assignment1
//
//  Created by Renzelle Frank V Rodrigueza on 2017-03-13.
//  Copyright © 2017 com.renzellerodrigueza. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {


    
    var dateTime: String = "" {
        didSet {
            if (dateTime != oldValue) {
                dateTimeLabel.text = dateTime
            }
        }
    }
    var location: String = "" {
        didSet {
            if (location != oldValue) {
                locationLabel.text = location
            }
        }
    }
    
    @IBOutlet var dateTimeLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
