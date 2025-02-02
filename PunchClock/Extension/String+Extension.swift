//
//  String+Extension.swift
//  PunchClock
//
//  Created by Jube on 2023/7/11.
//

import CommonCrypto
import Foundation.NSDate

extension String {
    var md5: String {
        let data = self.data(using: .utf8)!
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = data.withUnsafeBytes { (bytes) in
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &digest)
        }
        
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    
    func toTime(_ dateFormat: DateFormat) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat.rawValue
        
        return dateFormatter.date(from: self)
    }
}
