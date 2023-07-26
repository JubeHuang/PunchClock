//
//  MainViewController.swift
//  PunchClock
//
//  Created by Jube on 2023/7/11.
//

import UIKit
import Combine

class MainViewController: UIViewController {
    
    @IBOutlet weak var workingHourLabel: UILabel!
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var quoteTextField: UITextView!
    @IBOutlet weak var iconBgLayer: UIView!
    
    var viewModel = PunchClockViewModel()
    var cancellable = Set<AnyCancellable>()
    var checkInButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "checkIn"), for: .selected)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        renderUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModel.timerSubscriber?.cancel()
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
        
        viewModel.$workingHourStr
            .assign(to: \.text, on: workingHourLabel)
            .store(in: &cancellable)
        
        
        
        
    }
    
    private func renderUI() {
        iconBgLayer.layer.shadowColor = UIColor.shadowColor.cgColor
        iconBgLayer.layer.shadowOpacity = 1
        iconBgLayer.layer.shadowRadius = 10
        iconBgLayer.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        createCheckInButton()
    }
    
    private func createCheckInButton() {
        viewModel.$currentTimeStr
            .sink(receiveValue: { title in
                let attributedText = NSMutableAttributedString(string: title, attributes: [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 70, weight: .medium),
                    NSAttributedString.Key.foregroundColor: UIColor.darkBlue ?? .black
                ])
                
                self.checkInButton.setAttributedTitle(attributedText, for: .normal)
            })
            .store(in: &cancellable)
        
        view.addSubview(checkInButton)
        checkInButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkInButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            checkInButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
        ])
        
        checkInButton.setImage(UIImage(named: "checkOut"), for: .normal)
        checkInButton.setImage(UIImage(named: "checkIn"), for: .selected)
        checkInButton.addTarget(self, action: #selector(checkIn), for: .touchUpInside)
        
        checkInButton.layoutButtonImage(at: .Left, spacing: 10)
    }
    
    @objc private func checkIn() {
        viewModel.timerSubscriber?.cancel()
        
        checkInButton.isSelected = !checkInButton.isSelected
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
