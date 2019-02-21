//
//  SplashPresenter.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//


import UIKit

final class MainRouter: MainRouterProtocol {
    
    private let coordinator: MainCoordinator!
    
    init(_ coordinator: MainCoordinator) {
        self.coordinator = coordinator
    }
    
    func openPreview(photo: MainModel.Photo, imageView: UIImageView) {
        coordinator.openPreview(photo: photo, imageView: imageView)
    }
}
