//
//  MainViewController.swift
//  PunchClock
//
//  Created by Jube on 2023/7/11.
//

import UIKit
import Combine

class MainViewController: UIViewController {
    
    @IBOutlet weak var workingHourStack: UIStackView!
    @IBOutlet weak var workingHourLabel: UILabel!
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var quoteTextField: UITextView!
    @IBOutlet weak var iconBgLayer: UIView!
    
    var viewModel = PunchClockViewModel()
    var cancellable = Set<AnyCancellable>()
    
    let vibrateFeedback = UIImpactFeedbackGenerator(style: .medium)
    
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
        
        viewModel.$isCheckIn.sink { [weak self] isCheckIn in
            guard let self = self else { return }
            
            self.workingHourStack.isHidden = !isCheckIn
            self.viewModel.checkOutButton.isHidden = !isCheckIn
            self.viewModel.captionLabel.isHidden = isCheckIn
            
            let animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0.15, options: .curveEaseInOut) {
                self.workingHourStack.layer.opacity = isCheckIn ? 1 : 0
            }
            animator.addAnimations({
                self.viewModel.checkOutButton.layer.opacity = isCheckIn ? 1 : 0
            }, delayFactor: 0.3)
            
        }.store(in: &cancellable)
        
    }
    
    private func renderUI() {
        iconBgLayer.layer.shadowColor = UIColor.shadowColor.cgColor
        iconBgLayer.layer.shadowOpacity = 1
        iconBgLayer.layer.shadowRadius = 10
        iconBgLayer.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        viewModel.createCheckInButton(controller: self, action: #selector(checkIn))
        viewModel.createCheckOutButton(controller: self, action: #selector(checkOut))
        
        view.addSubview(viewModel.captionLabel)
        
        viewModel.captionLabel.translatesAutoresizingMaskIntoConstraints = false
        workingHourStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewModel.captionLabel.topAnchor.constraint(equalTo: viewModel.checkInButton.bottomAnchor),
            viewModel.captionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 96)
        ])
    }
    
    @objc private func checkIn(_ sender: UIButton) {
        viewModel.checkInButton.isSelected = true
        viewModel.checkInButton.isUserInteractionEnabled = false
        
        viewModel.punchInTimeStr = Date().toString(dateFormat: .hourMinute)
        viewModel.checkInButton.setTitle(string: viewModel.punchInTimeStr!, button: .work(state: .punchIn))
        
        vibrateFeedback.prepare()
        vibrateFeedback.impactOccurred(intensity: 3)
        
        viewModel.isCheckIn = true
    }
    
    @objc private func checkOut(_ sender: UIButton) {
        viewModel.checkOutButton.isSelected = true
        viewModel.checkOutButton.isUserInteractionEnabled = false
        
        viewModel.punchOutTimeStr = Date().toString(dateFormat: .hourMinute)
        viewModel.checkOutButton.setTitle(string: viewModel.punchOutTimeStr!, button: .offWork(state: .punchOut))
        
        vibrateFeedback.prepare()
        vibrateFeedback.impactOccurred(intensity: 3)
        
        viewModel.isCheckOut = false
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
