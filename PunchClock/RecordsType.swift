//
//  RecordsType.swift
//  PunchClock
//
//  Created by Jube on 2023/7/23.
//
import Combine

protocol RecordsType {
    
    func searchRecords(month: String) -> AnyPublisher<[TimeRecord], Never>
}
