//
//  timeButton.swift
//  PunchClock
//
//  Created by Jube on 2023/7/27.
//

import UIKit

class TimeButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleLabel?.textAlignment = .left
        self.contentHorizontalAlignment = .left
        
        self.setTitleColor(.darkBlue, for: .highlighted)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(button style: ButtonStyle) {
        switch style {
            
        case .work(_):
            self.setImage(WorkState.notPunchIn.image, for: .normal)
            self.setImage(WorkState.punchIn.image, for: .selected)
            
        case .offWork(_):
            self.setImage(OffWorkState.notPunchOut.image, for: .normal)
            self.setImage(OffWorkState.punchOut.image, for: .selected)
        }
    }
    
    func setTitle(string: String, button style: ButtonStyle) {
        switch style {
        case .work(let state):
            let attributedText = NSMutableAttributedString(string: string, attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 70, weight: .medium),
                NSAttributedString.Key.foregroundColor: state.color
            ])
            let controlState: UIControl.State = state == .notPunchIn ? .normal : .selected
            self.setAttributedTitle(attributedText, for: controlState)
            
        case .offWork(let state):
            let attributedText = NSMutableAttributedString(string: string, attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 70, weight: .medium),
                NSAttributedString.Key.foregroundColor: state.color
            ])
            let controlState: UIControl.State = state == .notPunchOut ? .normal : .selected
            self.setAttributedTitle(attributedText, for: controlState)
        }
    }
    
    func commonLayout(on view: UIView) {
        view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            self.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40)
        ])
    }
}

extension TimeButton {
    
    enum ButtonStyle {
        case work(state: WorkState)
        case offWork(state: OffWorkState)
    }
    
    enum WorkState {
        case notPunchIn
        case punchIn

        var color: UIColor {
            switch self {
            case .notPunchIn:
                return .primaryBlue ?? .black
            case .punchIn:
                return .darkBlue ?? .black
            }
        }

        var image: UIImage {
            switch self {
            case .notPunchIn:
                return UIImage(named: "checkNo")!
            case .punchIn:
                return UIImage(named: "checkIn")!
            }
        }
    }
    
    enum OffWorkState {
        case notPunchOut
        case punchOut

        var color: UIColor {
            switch self {
            case .notPunchOut:
                return .black70 ?? .black
            case .punchOut:
                return .darkBlue ?? .black
            }
        }

        var image: UIImage {
            switch self {
            case .notPunchOut:
                return UIImage(named: "notCheckOut")!
            case .punchOut:
                return UIImage(named: "checkOut")!
            }
        }
    }
}
