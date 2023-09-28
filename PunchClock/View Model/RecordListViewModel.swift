
//  RecordListViewModel.swift
//  PunchClock
//
//  Created by Jube on 2023/7/13.


import Foundation
import UIKit
import Combine

class RecordListViewModel {
    
    var records: [TimeRecord]
    var hasRecords: Bool { records.count > 0 }
    
    var selectedIndexPath: IndexPath?
    var isExpand: Bool = false
    
    let hours = (0...23).map {String(format: "%02d", $0)}
    let minustes = (0...59).map {String(format: "%02d", $0)}
    
    @Published var monthString = Date().toString(dateFormat: .monthEn)
    var monthInt = Int(Date().toString(dateFormat: .monthInt)) ?? 0 {
        didSet {
            if monthInt < 1 {
                monthInt = 12
            } else if monthInt > 12 {
                monthInt = 1
            }
        }
    }
    
    lazy var firestoreManager = FirestoreManager()
    
    init() {
        self.records = [TimeRecord]()
        firestoreManager.fetchData(in: monthString) { self.records = $0 }
    }
}

extension RecordListViewModel {
    
    func records(at index: Int) -> TimeRecord {
        return self.records[index]
    }
    
    func getPunchInStr(at index: Int) -> String {
        let record = records(at: index)
        return record.inTimeString
    }
    
    func getPunchOutStr(at index: Int) -> String {
        let record = records(at: index)
        return record.outTimeString
    }
    
    func getDateStr(at index: Int) -> String {
        let record = records(at: index)
        return record.dateString
    }
    
    func getWorkingHourStr(at index: Int) -> String {
        let record = records(at: index)
        let punchInTime = record.inTimeString
        let punchOutTime = record.outTimeString
        
        if punchInTime.count == 5, punchOutTime.count == 5 {
            if let inHour = Int(punchInTime.prefix(2)),
               let outHour = Int(punchOutTime.prefix(2)),
               let inMinute = Int(punchInTime.suffix(2)),
               let outMinute = Int(punchOutTime.suffix(2)) {
                let hours = outHour - inHour
                let minutes = outMinute - inMinute
                
                return "\(hours)小時\(minutes)分"
            }
        }
        return ""
    }
    
    func mayShowEmptyState(image: UIImageView, tableView: UITableView) {
        image.isHidden = hasRecords
        tableView.isHidden = !hasRecords
    }
    
    func nextMonth(emptyImage: UIImageView, tableView: UITableView) {
        monthInt += 1
        monthString = Month.allCases[monthInt - 1].value
        
        selectedIndexPath = nil
        
        fetchData(emptyImage: emptyImage, tableView: tableView)
    }
    
    func preMonth(emptyImage: UIImageView, tableView: UITableView) {
        monthInt -= 1
        monthString = Month.allCases[monthInt - 1].value
        
        selectedIndexPath = nil
        
        fetchData(emptyImage: emptyImage, tableView: tableView)
    }
    
    func saveEditTime(in tableView: UITableView, emptyImage: UIImageView) {
        guard let selectedCell = selectedCell(in: tableView) else { return }
        
        let punchInText = selectedCell.inTextfield.text
        let punchOutText = selectedCell.outTextfield.text
        
        if let punchInText, punchInText != "" {
            selectedCell.punchInLabel.text = punchInText
        }
        if let punchOutText,  punchOutText != "" {
            selectedCell.punchOutLabel.text = punchOutText
        }
        
        updateData(inTimeString: punchInText, outTimeString: punchOutText)
        
        selectedCell.toDefaultState()
        selectedCell.inTextfield.attributedPlaceholder = NSAttributedString(string: selectedCell.punchInLabel.text!, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white70!])
        selectedCell.outTextfield.attributedPlaceholder = NSAttributedString(string: selectedCell.punchOutLabel.text!, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white70!])
    }
    
    func cancelEditTime(in tableView: UITableView) {
        guard let selectedCell = selectedCell(in: tableView) else { return }
        selectedCell.toDefaultState()
        
        isExpand = false
    }
    
    func pickerDone(isInTime: Bool, in tableView: UITableView, picker: UIPickerView) {
        guard let selectedCell = selectedCell(in: tableView) else { return }
        selectedCell.toSaveUIState()
        
        let hourIndex = picker.selectedRow(inComponent: 0)
        let minIndex = picker.selectedRow(inComponent: 2)
        
        if isInTime {
            selectedCell.inTextfield.text = "\(hours[hourIndex]):\(minustes[minIndex])"
        } else {
            selectedCell.outTextfield.text = "\(hours[hourIndex]):\(minustes[minIndex])"
        }
    }
    
    private func selectedCell(in tableView: UITableView) -> RecordViewCell? {
        guard let selectedIndexPath else { return nil }
        return tableView.cellForRow(at: selectedIndexPath) as! RecordViewCell
    }
    
    private func setPickerDefaultValue(_ picker: UIPickerView, time: String, in textfield: UITextField? = nil) {
        let hourStr = String(textfield?.text?.prefix(2) ?? time.prefix(2))
        let minStr = String(textfield?.text?.suffix(2) ?? time.suffix(2))
        
        if let hourRow = hours.firstIndex(of: hourStr),
           let minRow = minustes.firstIndex(of: minStr) {
            picker.selectRow(hourRow, inComponent: 0, animated: true)
            picker.selectRow(minRow, inComponent: 2, animated: true)
        }
    }
    
    private func deleteRecord(at index: Int) {
        guard let documentID = records(at: index).documentID else { return }
        
        records.remove(at: index)
        
        firestoreManager.deleteData(in: monthString, at: index, with: documentID)
    }
    
    private func fetchData(emptyImage: UIImageView, tableView: UITableView) {
        firestoreManager.fetchData(in: monthString) { records in
            self.records = records
            
            self.mayShowEmptyState(image: emptyImage, tableView: tableView)
            
            tableView.reloadData()
            print("monthInt:\(self.monthInt), recordsCounts: \(self.records.count)")
        }
        print(records.count, "records \(monthString)", hasRecords)
    }
    
    private func updateData(inTimeString: String?, outTimeString: String?) {
        var inTime = records(at: selectedIndexPath!.row).inTime
        var outTime = records(at: selectedIndexPath!.row).outTime
        
        let calandar = Calendar.current
        let inTimeComponent = inTimeString?.components(separatedBy: ":")
        let outTimeComponent = outTimeString?.components(separatedBy: ":")
        if let hour = Int(inTimeComponent![0]),
           let min = Int(inTimeComponent![1]) {
            inTime = calandar.date(bySettingHour: hour, minute: min, second: 0, of: inTime!) ?? inTime
        }
        if let hour = Int(outTimeComponent![0]),
           let min = Int(outTimeComponent![1]) {
            outTime = calandar.date(bySettingHour: hour, minute: min, second: 0, of: outTime!) ?? outTime
        }
        
        firestoreManager.updateData(in: monthString, index: selectedIndexPath!.row, in: inTime, out: outTime)
    }
}

extension RecordListViewModel {
    
    func configCell(_ cell: RecordViewCell, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        cell.punchInLabel.text = getPunchInStr(at: row)
        cell.punchOutLabel.text = getPunchOutStr(at: row)
        cell.workingHourLabel.text = getWorkingHourStr(at: row)
        cell.dateLabel.text = getDateStr(at: row)
        
        cell.inTextfield.attributedPlaceholder = NSAttributedString(string: getPunchInStr(at: row), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white70!])
        cell.outTextfield.attributedPlaceholder = NSAttributedString(string: getPunchOutStr(at: row), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white70!])
        
        let imageColorNames = ["R", "B", "P", "Y", "G"]
        cell.leftCircleImage.image = UIImage(named: "circleLeft" + imageColorNames[row % 5])
        cell.rightCircleImage.image = UIImage(named: "circleRight" + imageColorNames[row % 5])
        
        return cell
    }
    
    func deleteCell(_ tableView: UITableView, emptyImage: UIImageView, cellForRowAt indexPath: IndexPath) {
        deleteRecord(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        mayShowEmptyState(image: emptyImage, tableView: tableView)
    }
    
    func selectedRowAt(indexPath: IndexPath, pickers:[UIPickerView]) {
        if selectedIndexPath == indexPath {
            isExpand = !isExpand
        } else {
            selectedIndexPath = indexPath
            isExpand = true
        }
        
        setPickerDefaultValue(pickers[0], time: getPunchInStr(at: indexPath.row))
        setPickerDefaultValue(pickers[1], time: getPunchOutStr(at: indexPath.row))
        
    }
    
}
