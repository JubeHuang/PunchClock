//
//  RecordViewCell.swift
//  PunchClock
//
//  Created by Jube on 2023/8/16.
//

import UIKit

class RecordViewCell: UITableViewCell {

    @IBOutlet weak var adjustLabel: UILabel!
    @IBOutlet weak var outTextfield: UITextField!
    @IBOutlet weak var inTextfield: UITextField!
    @IBOutlet weak var saveBtn: ExpandTouchAreaButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cancelBtn: ExpandTouchAreaButton!
    @IBOutlet weak var rightCircleImage: UIImageView!
    @IBOutlet weak var leftCircleImage: UIImageView!
    @IBOutlet weak var punchInLabel: UILabel!
    @IBOutlet weak var punchOutLabel: UILabel!
    @IBOutlet weak var workingHourLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        toDefaultState()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func toSaveUIState() {
        cancelBtn.isHidden = false
        adjustLabel.isHidden = true
        saveBtn.isUserInteractionEnabled = true
        saveBtn.setTitleColor(.secondaryRed, for: .normal)
    }
    
    func toDefaultState() {
        cancelBtn.touchEdgeInsets = UIEdgeInsets(top: -16, left: -16, bottom: -16, right: -16)
        saveBtn.touchEdgeInsets = UIEdgeInsets(top: -16, left: -16, bottom: -16, right: -16)
        
        cancelBtn.isHidden = true
        adjustLabel.isHidden = false
        saveBtn.isUserInteractionEnabled = false
        saveBtn.setTitleColor(.black70, for: .normal)
        inTextfield.text = nil
        outTextfield.text = nil
    }
}
