//
//  MainCoordinator.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//

import UIKit

class MainCoordinator {
    
    private let _navigation: UINavigationController
    
    init(_ navigation: UINavigationController) {
        _navigation = navigation
    }
    
    func start() {
        let deps = SplashAssembly.Dependencies()
        let splashVC = SplashAssembly(deps).build()
        _navigation.pushViewController(splashVC, animated: false)
    }
    
}
