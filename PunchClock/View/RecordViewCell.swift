//
//  RecordViewCell.swift
//  PunchClock
//
//  Created by Jube on 2023/8/16.
//

import UIKit

class RecordViewCell: UITableViewCell {

    @IBOutlet weak var punchInLabel: UILabel!
    @IBOutlet weak var punchOutLabel: UILabel!
    @IBOutlet weak var workingHourLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
