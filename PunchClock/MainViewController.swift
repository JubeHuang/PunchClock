//
//  MainViewController.swift
//  PunchClock
//
//  Created by Jube on 2023/7/11.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signIn(_ sender: Any) {
        LogInManager().appleSignIn()
    }
    
    @IBAction func addData(_ sender: Any) {
        FirestoreManager().createData(month: Month.Jul.value, in: Date())
    }
    
    @IBAction func readData(_ sender: Any) {
        
        FirestoreManager().fetchData(month: Month.Jul.value) { timeRecords in
            
            timeRecords.forEach { record in
                
                self.label.text = (record.inTime?.toString() ?? "") + (record.outTime?.toTimeString() ?? "")
                
            }
        }
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
