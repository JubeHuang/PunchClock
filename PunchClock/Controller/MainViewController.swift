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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        renderUI()
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
        
        viewModel.$workingHourStr
            .assign(to: \.text, on: workingHourLabel)
            .store(in: &cancellable)
        
        viewModel.$isPunchIn
            .sink { [weak self] isPunchIn in
                guard let self = self else { return }
                
                self.workingHourStack.isHidden = !isPunchIn
                
                let animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0.15, options: .curveEaseInOut) {
                    self.workingHourStack.layer.opacity = isPunchIn ? 1 : 0
                }
                animator.addAnimations({
                    self.viewModel.checkOutButton.layer.opacity = isPunchIn ? 1 : 0
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
        NSLayoutConstraint.activate([
            viewModel.captionLabel.topAnchor.constraint(equalTo: viewModel.checkInButton.bottomAnchor),
            viewModel.captionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 96)
        ])
    }
    
    @objc private func checkIn(_ sender: UIButton) {
        viewModel.isPunchIn = true
        
        viewModel.vibrate()
    }
    
    @objc private func checkOut(_ sender: UIButton) {
        viewModel.isPunchOut = true
        
        viewModel.vibrate()
        
        viewModel.displayAlert(self, title: "恭喜打卡完成", message: "趕快飛奔下班吧～")
    }
}
