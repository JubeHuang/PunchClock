//
//  MainViewController.swift
//  PunchClock
//
//  Created by Jube on 2023/7/11.
//

import UIKit
import Combine

class MainViewController: UIViewController {
    
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var quoteTextField: UITextView!
    @IBOutlet weak var iconBgLayer: UIView!
    
    var viewModel: PunchClockViewModel!
    var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        render()
        
        bind()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
    }
    
    func bind() {
        viewModel.$quoteSubject
            .assign(to: \.text, on: quoteTextField)
            .store(in: &cancellable)
        
        viewModel.$dateStr
            .assign(to: \.text! , on: dateLabel)
            .store(in: &cancellable)
        
        viewModel.$weekDayStr
            .assign(to: \.text!, on: weekdayLabel)
            .store(in: &cancellable)
        
        
    }
    
    private func render() {
        iconBgLayer.layer.shadowColor = UIColor(red: 0.631, green: 0.678, blue: 0.722, alpha: 0.3).cgColor
        iconBgLayer.layer.shadowOpacity = 1
        iconBgLayer.layer.shadowRadius = 10
        iconBgLayer.layer.shadowOffset = CGSize(width: 0, height: 2)
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
