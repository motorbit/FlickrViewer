//
//  SplashAssembly.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//

import UIKit

protocol MainCoordinator {
    
}

class MainAssembly: Assembly {
    
    private let deps: Dependencies
    
    struct Dependencies {
        let flickerService: FlickerServiceProtocol
        let coordinator: MainCoordinator
    }
    
    init(_ deps: Dependencies) {
        self.deps = deps
    }
    
    func build() -> UIViewController {
        let view = MainViewController()
        let presenter = MainPresenter()
        let interactor = MainInteractor(self.deps.flickerService)
        let router = MainRouter()
        // Connecting
        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        
        return view
    }
    
}