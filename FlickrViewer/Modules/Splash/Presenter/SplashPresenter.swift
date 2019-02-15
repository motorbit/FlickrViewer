//
//  SplashPresenter.swift
//  FlickerViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//

class SplashPresenter: SplashPresenterProtocol, SplashInteractorOutput {
    
    weak var view: SplashViewInput?
    var interactor: SplashInteractorInput!
    var router: SplashRouterProtocol!
    
}


