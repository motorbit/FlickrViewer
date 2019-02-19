//
//  SplashPresenter.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//


import UIKit

class SplashRouter: SplashRouterProtocol {
    
    private let coordinator: SplashCoordinator!
    
    init(_ coordinator: SplashCoordinator) {
        self.coordinator = coordinator
    }
    
    func showMainScreen() {
        coordinator.showMainScreen()
    }
}
