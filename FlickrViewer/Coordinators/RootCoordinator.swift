//
//  MainCoordinator.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//

import UIKit

class RootCoordinator: SplashCoordinator, MainCoordinator {
    
    private let _navigation: UINavigationController
    
    init(_ navigation: UINavigationController) {
        _navigation = navigation
    }
    
    func start() {
        let deps = SplashAssembly.Dependencies(coordinator: self)
        let splashVC = SplashAssembly(deps).build()
        _navigation.pushViewController(splashVC, animated: false)
    }
    
    func showMainScreen() {
        let deps = MainAssembly.Dependencies(flickerService: ServiceFactory().makeFlickerService(),
                                             coordinator: self)
        let mainVC = MainAssembly(deps).build()
        _navigation.pushViewController(mainVC, animated: true)
        _navigation.viewControllers = [mainVC]
    }
    
    func openPreview(photo: MainModel.Photo, imageView: UIImageView) {
        let transitionInfo = PhotoPreviewTransitionInfo(
            interactiveDismissalEnabled: true,
            startingView: imageView,
            endingView: imageView)
        
        let deps = PhotoPreviewAssembly.Dependencies(photo: photo, transitionInfo: transitionInfo)
        let previewVC = PhotoPreviewAssembly(deps).build()
        
        _navigation.present(previewVC, animated: true, completion: nil)
    }
    
}
