//
//  MainViewController.swift
//  PunchClock
//
//  Created by Jube on 2023/7/11.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var iconBgLayer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iconBgLayer.layer.shadowColor = UIColor(red: 0.631, green: 0.678, blue: 0.722, alpha: 0.3).cgColor
        iconBgLayer.layer.shadowOpacity = 1
        iconBgLayer.layer.shadowRadius = 10
        iconBgLayer.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        // Do any additional setup after loading the view.
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
