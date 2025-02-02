//
//  Url+Extension.swift
//  PunchClock
//
//  Created by Jube on 2023/8/17.
//

import Foundation.NSURL

extension URL {
    
    func withQuery(_ queries: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = queries.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        
        return components?.url
    }
    
    func add<T:Codable>(param: T) -> URL? {
        guard let paramData = try? JSONEncoder().encode(param),
              let paramDictionary = try? JSONSerialization.jsonObject(with: paramData) as? [String: String] else { return nil }
        
        return self.withQuery(paramDictionary)
    }
}
