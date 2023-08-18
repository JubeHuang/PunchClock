//
//  TableViewController.swift
//  PunchClock
//
//  Created by Jube on 2023/7/25.
//

import UIKit
import Combine

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var minusBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var offWorkPushSwitch: UISwitch!
    @IBOutlet weak var autoPunchOutSwitch: UISwitch!
    @IBOutlet weak var hoursLabel: UILabel!
    
    let viewModel = SettingViewModel(workingHours: 9.0)
    var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        bind()
        viewModel.syncPushStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.saveDataToUserDefault()
        cancellable.removeAll()
    }

    func bind() {
        viewModel.$workingHours
            .map({ return "\($0)" })
            .assign(to: \.text, on: hoursLabel)
            .store(in: &cancellable)
        
        viewModel.$isAutoPunchOutOn
            .receive(on: DispatchQueue.main)
            .assign(to: \.isOn, on: autoPunchOutSwitch)
            .store(in: &cancellable)
        
        viewModel.$isOffWorkPushOn
            .receive(on: DispatchQueue.main)
            .assign(to: \.isOn, on: offWorkPushSwitch)
            .store(in: &cancellable)
    }
    
    @IBAction func add(_ sender: Any) {
        viewModel.addHours()
        
        addBtn.isEnabled = viewModel.isAddBtnEnabled
        minusBtn.isEnabled = viewModel.isMinusBtnEnabled
    }
    
    @IBAction func minus(_ sender: Any) {
        viewModel.minusHours()
        
        addBtn.isEnabled = viewModel.isAddBtnEnabled
        minusBtn.isEnabled = viewModel.isMinusBtnEnabled
    }
    
    @IBAction func autoPunchOut(_ sender: UISwitch) {
        viewModel.isAutoPunchOutOn = sender.isOn
    }
    
    @IBAction func punchOutPush(_ sender: UISwitch) {
        viewModel.isOffWorkPushOn = sender.isOn
        
        viewModel.checkPushState()
    }
    
}
