//
//  SplashPresenter.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
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
