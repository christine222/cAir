//
//  CustomCell.swift
//  cAir
//
//  Created by Taco on 8/3/16.
//  Copyright © 2016 Taco. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBOutlet weak var sampleLabel: UILabel!
    @IBOutlet weak var sampleDate: UILabel!
    @IBOutlet weak var sampleTime: UILabel!
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    
    }

}
