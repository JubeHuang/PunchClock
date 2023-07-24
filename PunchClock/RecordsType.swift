//
//  RecordsType.swift
//  PunchClock
//
//  Created by Jube on 2023/7/23.
//
import Combine

protocol RecordsType {
    
    func searchRecords(in month: String) -> AnyPublisher<[TimeRecord], Never>
    
    func recordDetail(with id: String, in month: String) -> AnyPublisher<TimeRecord, Never>
}
