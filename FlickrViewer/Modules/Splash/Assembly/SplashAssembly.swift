//
//  SplashAssembly.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//

import UIKit

protocol SplashCoordinator {
    func showMainScreen()
}

final class SplashAssembly: Assembly {
    
    private let deps: Dependencies
    
    struct Dependencies {
        let coordinator: SplashCoordinator
    }
    
    init(_ deps: Dependencies) {
        self.deps = deps
    }
    
    func build() -> UIViewController {
        let view = SplashViewController()
        let presenter = SplashPresenter()
        let router = SplashRouter(deps.coordinator)
        // Connecting
        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        
        return view
    }
    
}
