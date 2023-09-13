
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
    
    func getWorkingHourStr(at index: Int) -> String {
        let record = records(at: index)
        
        guard let punchInTime = record.inTime, let punchOutTime = record.outTime else { return "太長了" }
        let seconds = punchOutTime.timeIntervalSince(punchInTime)
        
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        
        return "\(hours)時\(minutes)分"
    }
    
    func mayShowEmptyState(image: UIImageView, tableView: UITableView) {
        image.isHidden = hasRecords
        tableView.isHidden = !hasRecords
    }
    
    private func fetchData(image: UIImageView, tableView: UITableView) {
        firestoreManager.fetchData(in: monthString) { records in
            self.records = records
            
            self.mayShowEmptyState(image: image, tableView: tableView)
            
            tableView.reloadData()
            print("monthInt:\(self.monthInt), recordsCounts: \(self.records.count)")
        }
        print(records.count, "records \(monthString)", hasRecords)
    }
    
    func nextMonth(image: UIImageView, tableView: UITableView) {
        monthInt += 1
        monthString = Month.allCases[monthInt - 1].value
        fetchData(image: image, tableView: tableView)
    }
    
    func preMonth(image: UIImageView, tableView: UITableView) {
        monthInt -= 1
        monthString = Month.allCases[monthInt - 1].value
        fetchData(image: image, tableView: tableView)
    }
    
    private func deleteRecord(at index: Int) {
        guard let documentID = records(at: index).documentID else { return }
        
        records.remove(at: index)
        
        firestoreManager.deleteData(in: monthString, at: index, with: documentID)
    }
}

extension RecordListViewModel {
    
    func configCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(RecordViewCell.self)", for: indexPath) as! RecordViewCell
        let row = indexPath.row
        
        cell.punchInLabel.text = getPunchInStr(at: row)
        cell.punchOutLabel.text = getPunchOutStr(at: row)
        cell.workingHourLabel.text = getWorkingHourStr(at: row)
        
        return cell
    }
    
    func deleteCell(_ tableView: UITableView, imageView: UIImageView, cellForRowAt indexPath: IndexPath) {
        deleteRecord(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        mayShowEmptyState(image: imageView, tableView: tableView)
    }
}
