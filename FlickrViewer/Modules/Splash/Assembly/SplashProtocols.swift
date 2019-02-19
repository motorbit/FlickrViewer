//
//  SplashProtocols.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//


import UIKit

protocol SplashRouterProtocol: class {
    func showMainScreen()
}

protocol SplashViewInput: class {
}

protocol SplashPresenterProtocol: class {
    func showed()
}
