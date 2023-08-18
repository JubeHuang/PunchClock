//
//  RecordListViewController.swift
//  PunchClock
//
//  Created by Jube on 2023/7/13.
//

import UIKit
import Combine

class RecordListViewController: UIViewController {
    
    @IBOutlet weak var recordListTableView: UITableView!
    @IBOutlet weak var monthLabel: UILabel!
    
    var viewModel = RecordListViewModel()
    var cancellable = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bind()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        cancellable.removeAll()
    }
    
    func bind() {
        viewModel.$monthString
            .map({ $0.uppercased() })
            .assign(to: \.text!, on: monthLabel)
            .store(in: &cancellable)
    }
    
    @IBAction func nextMonth(_ sender: Any) {
        viewModel.nextMonth()
        
        recordListTableView.reloadData()
    }
    
    @IBAction func preMonth(_ sender: Any) {
        viewModel.preMonth()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RecordListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        viewModel.configCell(tableView, cellForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        viewModel.deleteCell(tableView,
                             view: view,
                             cellForRowAt: indexPath)
    }
}
