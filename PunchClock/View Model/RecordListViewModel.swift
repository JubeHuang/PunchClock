
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
    var monthInt: Int = {Int(Date().toString(dateFormat: .monthInt)) ?? 0}()
    
    lazy var firestoreManager = FirestoreManager()
    

    init() {
        self.records = [TimeRecord]()

        fetchData()
        print(monthInt)
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
        let text = Wording.duration.text
        
        guard let punchInTime = record.inTime, let punchOutTime = record.outTime else { return text + "太長了" }
        let seconds = punchInTime.timeIntervalSince(punchOutTime)
        
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        
        return text + "\(hours) 小時 \(minutes) 分鐘"
    }
    
    func mayShowEmptyState(_ view: UIView) {
        if !hasRecords {
            let emptyImageView = UIImageView(image: UIImage(named: "12"))
            emptyImageView.contentMode = .scaleAspectFit
            emptyImageView.backgroundColor = .black
            view.addSubview(emptyImageView)
            
            emptyImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                emptyImageView.widthAnchor.constraint(equalToConstant: 200),
                emptyImageView.heightAnchor.constraint(equalToConstant: 200)
            ])
        }
    }

    private func fetchData() {
        firestoreManager.fetchData(in: monthString) { self.records = $0 }
        print(records.count, "records")
    }
    
    func nextMonth() {
        let index = monthInt % Month.allCases.count
        monthString = Month.allCases[index].value
        
        monthInt = (monthInt + 1) % 12
        
        fetchData()
    }
    
    func preMonth() {
        let index = (monthInt + Month.allCases.count - 1) % Month.allCases.count
        monthString = Month.allCases[index].value
        
        monthInt = (monthInt + Month.allCases.count - 1) % Month.allCases.count
    
        fetchData()
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
    
    func deleteCell(_ tableView: UITableView, view: UIView, cellForRowAt indexPath: IndexPath) {
        deleteRecord(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        mayShowEmptyState(view)
    }
}
