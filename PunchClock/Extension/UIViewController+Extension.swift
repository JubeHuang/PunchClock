//
//  UIViewController+Extension.swift
//  PunchClock
//
//  Created by Jube on 2023/8/3.
//

import UIKit

extension UIViewController {
    
    func displayAlert(title: String? = nil, message: String? = nil, actionTitle: String = "YAY") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: actionTitle, style: .default)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true)
    }
    
    func displayAlert(title: String? = nil, message: String? = nil, actionTitle: String = "YAY", handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: actionTitle, style: .default, handler: handler)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true)
    }
}
