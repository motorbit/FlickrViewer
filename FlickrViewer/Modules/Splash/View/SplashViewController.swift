//
//  SplashPresenter.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//


import UIKit
import SnapKit

final class SplashViewController: UIViewController, SplashViewInput {
    
    var presenter: SplashPresenterProtocol!
    
    private lazy var blueCircle: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.colors.blue.stringToUIColor()
        view.clipsToBounds = true
        view.layer.cornerRadius = Constraints.circle.width / 2
        self.view.addSubview(view)
        
        view.snp.makeConstraints({ make in
            make.width.height.equalTo(Constraints.circle.width)
            make.centerY.equalTo(self.view)
            make.left.equalTo(self.view).offset(Constraints.circle.padding)
        })
        return view
    }()
    
    private lazy var pinkCircle: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.colors.pink.stringToUIColor()
        view.clipsToBounds = true
        view.layer.cornerRadius = Constraints.circle.width / 2
        self.view.addSubview(view)
        
        view.snp.makeConstraints({ make in
            make.width.height.equalTo(Constraints.circle.width)
            make.centerY.equalTo(self.view)
            make.right.equalTo(self.view).offset(-Constraints.circle.padding)
        })
        return view
    }()
    
    private lazy var circlesLabel: UILabel = {
        let lbl = UILabel()
        let text = "FV"
        lbl.font = UIFont(name: Constants.fonts.boldItalic, size: Constraints.circlesLabel.fontSize)
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.kern, value: CGFloat(-11.24), range: NSRange(location: 0, length: 2))
        
        lbl.attributedText = attributedString

        lbl.textColor = Constants.colors.white.stringToUIColor()
        self.view.addSubview(lbl)
        
        lbl.snp.makeConstraints({ make in
            make.center.equalTo(self.view)
            make.width.equalTo(Constraints.circlesLabel.textWidth)
            make.height.equalTo(Constraints.circlesLabel.textHeight)
        })
        return lbl
    }()
    
    private lazy var appNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Constants.fonts.medium, size: Constraints.appNameLabel.fontSize)
        lbl.text = "Flicker Viewer"
        lbl.textColor = Constants.colors.textColor.stringToUIColor()
        self.view.addSubview(lbl)
        
        lbl.snp.makeConstraints({ make in
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.blueCircle.snp.bottom).offset(Constraints.appNameLabel.offset)
            make.width.equalTo(Constraints.appNameLabel.textWidth)
            make.height.equalTo(Constraints.appNameLabel.textHeight)
        })
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Constants.colors.white.stringToUIColor()
        startAnimation()
    }
    
    private func startAnimation() {
        pinkCircle.alpha = 0
        blueCircle.alpha = 0
        UIView.animate(withDuration: AnimationDuration.uprise, animations: { [unowned self] in
            self.blueCircle.alpha = 0.95
            self.pinkCircle.alpha = 1
        }) { _ in
            self.moveAnimation()
        }
    }
    
    private func moveAnimation() {
        UIView.animate(withDuration: AnimationDuration.move, animations: { [unowned self] in
            self.blueCircle.snp.remakeConstraints ({ make in
                make.width.height.equalTo(Constraints.circle.width)
                make.centerY.equalTo(self.view)
                make.centerX.equalTo(self.view).offset(-Constraints.circle.centerPadding)
            })
            self.pinkCircle.snp.remakeConstraints ({ make in
                make.width.height.equalTo(Constraints.circle.width)
                make.centerY.equalTo(self.view)
                make.centerX.equalTo(self.view).offset(Constraints.circle.centerPadding)
            })
            self.view.layoutIfNeeded()
        }) { _ in
            self.showTextAnimation()
        }
    }
    
    private func showTextAnimation() {
        self.circlesLabel.alpha = 0
        self.appNameLabel.alpha = 0
        UIView.animate(withDuration: AnimationDuration.uprise, animations: { [unowned self] in
            self.circlesLabel.alpha = 1
            self.appNameLabel.alpha = 1
        }) { _ in
            self.presenter.showed()
        }
    }
}

extension SplashViewController {
    
    enum Constraints {
        
        enum circle {
            static let width = CGFloat(140.adjustedByWidth)
            static let padding = CGFloat(10.adjustedByWidth)
            static let centerPadding = CGFloat(20.adjustedByWidth)
        }
        
        enum circlesLabel {
            static let textWidth = CGFloat(110.adjustedByWidth)
            static let textHeight = CGFloat(105.adjustedByWidth)
            static let fontSize = CGFloat(88.adjustedByWidth)
        }
        
        enum appNameLabel {
            static let textWidth = CGFloat(115.adjustedByWidth)
            static let textHeight = CGFloat(22.adjustedByWidth)
            static let fontSize = CGFloat(18.adjustedByWidth)
            static let offset = circle.width * 0.18
        }
    }
    
    enum AnimationDuration {
        static let uprise = 0.25
        static let move = 1.25
    }
}
