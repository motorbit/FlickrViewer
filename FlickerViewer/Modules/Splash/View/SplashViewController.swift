//
//  SplashSplashViewController.swift
//  Nynja
//
//  Created by Anton Makarov on 23/08/2017.
//  Copyright © 2017 TecSynt Solutions. All rights reserved.
//

import UIKit

final class SplashViewController: UIViewController, SplashViewInput {
    
    var presenter: SplashPresenterProtocol!
    
    private lazy var splashView: UIView = {
        let launchScreen = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()!
        let launchView = launchScreen.view!
        
        view.addSubview(launchView)
        
        return launchView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        splashView.isHidden = false
    }
}
