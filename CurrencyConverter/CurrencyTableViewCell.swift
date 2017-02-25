//
//  CurrencyTableViewCell.swift
//  CurrencyConverter
//
//  Created by Tova Grobert on 2/24/17.
//  Copyright © 2017 Toes. All rights reserved.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {

    @IBOutlet weak var flagView: UIImageView!
    
    @IBOutlet weak var codeView: UILabel!

    @IBOutlet weak var rateView: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
