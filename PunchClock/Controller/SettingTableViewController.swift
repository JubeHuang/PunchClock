//
//  TableViewController.swift
//  PunchClock
//
//  Created by Jube on 2023/7/25.
//

import UIKit

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var addHourBtn: UIButton!
    @IBOutlet weak var minusHourBtn: UIButton!
    @IBOutlet weak var offWorkPushSwitch: UISwitch!
    @IBOutlet weak var autoPunchOutSwitch: UISwitch!
    @IBOutlet weak var hoursLabel: UILabel!
    
    let viewModel = SettingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    
}
