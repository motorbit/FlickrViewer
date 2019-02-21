//
//  SplashPresenter.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//

final class SplashPresenter: SplashPresenterProtocol {
    
    weak var view: SplashViewInput?
    var router: SplashRouterProtocol!
 
    func showed() {
        self.router.showMainScreen()
    }
}


