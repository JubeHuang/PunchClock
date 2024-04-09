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
    @IBOutlet weak var emptyImage: UIImageView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    var viewModel = RecordListViewModel()
    var cancellable = Set<AnyCancellable>()
    
    var tableview: UITableView?
    let inTimePicker = UIPickerView()
    let outTimePicker = UIPickerView()
    var inToolBar: UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let cancelBtn = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(pickerCancel))
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(inPickerDone))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelBtn, flexibleSpace, doneBtn], animated: true)
        return toolBar
    }
    var outToolBar: UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let cancelBtn = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(pickerCancel))
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(outPickerDone))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelBtn, flexibleSpace, doneBtn], animated: true)
        return toolBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        bind()
        settingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.fetchData(emptyImage: emptyImage, tableView: recordListTableView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        cancellable.removeAll()
    }
    
    func settingView() {
        recordListTableView.estimatedRowHeight = UITableView.automaticDimension
        
        inTimePicker.delegate = self
        inTimePicker.dataSource = self
        outTimePicker.delegate = self
        outTimePicker.dataSource = self
    }
    
    @objc func inPickerDone() {
        self.view.endEditing(true)
        
        viewModel.pickerDone(isInTime: true,
                             in: recordListTableView,
                             picker: inTimePicker)
    }
    
    @objc func outPickerDone() {
        self.view.endEditing(true)
        
        viewModel.pickerDone(isInTime: false,
                             in: recordListTableView,
                             picker: outTimePicker)
    }
    
    @objc func pickerCancel() {
        self.view.endEditing(true)
    }
    
    func bind() {
        viewModel.$monthString
            .map({ $0.uppercased() })
            .assign(to: \.text!, on: monthLabel)
            .store(in: &cancellable)
        
        viewModel.$yearString
            .assign(to: \.text!, on: yearLabel)
            .store(in: &cancellable)
    }
    
    func createBlackView() -> UIView {
        let blackView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        blackView.backgroundColor = .darkBlue?.withAlphaComponent(0.5)
        blackView.isUserInteractionEnabled = false
        blackView.alpha = 0
        self.view.addSubview(blackView)
        
        return blackView
    }
    
    @IBAction func nextMonth(_ sender: Any) {
        viewModel.nextMonth(emptyImage: emptyImage, tableView: recordListTableView)
    }
    
    @IBAction func preMonth(_ sender: Any) {
        viewModel.preMonth(emptyImage: emptyImage, tableView: recordListTableView)
    }
    
    @IBAction func saveEditTime(_ sender: Any) {
        viewModel.saveEditTime(in: recordListTableView,
                               emptyImage: emptyImage,
                               onFailure: { text in
            self.displayAlert(title: "Oops", message: text, actionTitle: "OK")
        })
        tableView(tableview!, heightForRowAt: viewModel.selectedIndexPath!)
    }
    
    @IBAction func cancelEditTime(_ sender: Any) {
        viewModel.cancelEditTime(in: recordListTableView)
    }
}

extension RecordListViewController: UITableViewDelegate, UITableViewDataSource {
    var table: Int? {
        return 9
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(RecordViewCell.self)", for: indexPath) as! RecordViewCell
        
        cell.inTextfield.inputAccessoryView = inToolBar
        cell.inTextfield.inputView = inTimePicker
        cell.outTextfield.inputAccessoryView = outToolBar
        cell.outTextfield.inputView = outTimePicker
        
        return viewModel.configCell(cell, cellForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        viewModel.deleteCell(tableView,
                             emptyImage: emptyImage,
                             cellForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.tableview = tableView
        return (viewModel.selectedIndexPath == indexPath && viewModel.isExpand) ? 188 : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedRowAt(indexPath: indexPath, pickers: [inTimePicker, outTimePicker])
        
        tableView.performBatchUpdates{
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3,
                                                           delay: 0.1,
                                                           options: .curveEaseInOut) {
                tableView.scrollToRow(at: indexPath,
                                      at: .none,
                                      animated: true)
            }
        }
    }
}

extension RecordListViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        component == 0 ? 24 : (component == 1) ? 1 : 60
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        component == 0 ? viewModel.hours[row] : (component == 1) ? ":" : viewModel.minustes[row]
    }
}

extension RecordListViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        let blackView = createBlackView()
//        
//        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {
//            blackView.alpha = 1
//        }
    }
}
