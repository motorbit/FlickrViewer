//
//  SplashAssembly.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//

import UIKit

class SplashAssembly: Assembly {
    
    struct Dependencies {
        
    }
    
    init(_ deps: Dependencies) {
        
    }
    
    func build() -> UIViewController {
        let view = SplashViewController()
        let presenter = SplashPresenter()
        let interactor = SplashInteractor()
        let router = SplashRouter()
        // Connecting
        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        
        
        
        return view
    }
    
}
