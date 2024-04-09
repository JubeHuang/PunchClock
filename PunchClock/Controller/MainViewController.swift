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
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    var viewModel = PunchClockViewModel()
    var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bind()
        viewModel.checkAutoPunchOut()
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        cancellable.removeAll()
    }
    
    func bind() {
        viewModel.$quoteStr
            .assign(to: \.text, on: quoteTextField)
            .store(in: &cancellable)
        
        viewModel.$dateStr
            .assign(to: \.text!, on: dateLabel)
            .store(in: &cancellable)
        
        viewModel.$weekDayStr
            .assign(to: \.text!, on: weekdayLabel)
            .store(in: &cancellable)
        
        viewModel.weatherService?.$weatherInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] weatherInfo in
                self?.cityLabel.text = weatherInfo.city
                self?.weatherImageView.image = UIImage(named: weatherInfo.iconName)
            }.store(in: &cancellable)
        
        viewModel.$isPunchIn
            .sink { [weak self] isPunchIn in
                guard let self = self else { return }
                
                self.workingHourStack.isHidden = !isPunchIn
                
                let opacity: Float = isPunchIn ? 1 : 0
                
                let animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5,
                                                                              delay: 0.15,
                                                                              options: .curveEaseInOut) {
                    self.workingHourStack.layer.opacity = opacity
                }
                animator.addAnimations({
                    self.viewModel.checkOutButton.layer.opacity = opacity
                    self.viewModel.suggestTimeLabel.layer.opacity = opacity
                }, delayFactor: 0.3)
            }.store(in: &cancellable)
        
        workingHourLabel.text = viewModel.workingHourStr
        viewModel.getSuggestTimeStr()
    }
    
    private func renderUI() {
        iconBgLayer.layer.shadowColor = UIColor.shadowColor.cgColor
        iconBgLayer.layer.shadowOpacity = 1
        iconBgLayer.layer.shadowRadius = 10
        iconBgLayer.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        viewModel.createCheckInButton(controller: self, action: #selector(checkIn))
        viewModel.createCheckOutButton(controller: self, action: #selector(checkOut))
        
        addLabelUnderBtn()
    }
    
    private func addLabelUnderBtn() {
        view.addSubview(viewModel.captionLabel)
        view.addSubview(viewModel.suggestTimeLabel)
        
        viewModel.captionLabel.translatesAutoresizingMaskIntoConstraints = false
        viewModel.suggestTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewModel.captionLabel.topAnchor.constraint(equalTo: viewModel.checkInButton.bottomAnchor),
            viewModel.captionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 96),
            viewModel.suggestTimeLabel.topAnchor.constraint(equalTo: viewModel.checkOutButton.bottomAnchor),
            viewModel.suggestTimeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 96),
            viewModel.suggestTimeLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40)
        ])
    }
    
    @objc private func checkIn(_ sender: UIButton) {
        viewModel.isPunchIn = true
        
        viewModel.vibrate()
    }
    
    @objc private func checkOut(_ sender: UIButton) {
        viewModel.isPunchOut = true
        
        viewModel.vibrate()
        
        self.displayAlert(title: "恭喜打卡完成", message: "趕快飛奔下班吧～") { [weak self] _ in
            self?.viewModel.resetData()
        }
    }
    @IBAction func test(_ sender: Any) {
        WeatherService().getWeatherState(city: "臺北市")
    }
}
