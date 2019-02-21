//
//  SplashAssembly.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//

import UIKit

final class PhotoPreviewAssembly: Assembly {
    
    private let deps: Dependencies
    
    struct Dependencies {
        let photo: MainModel.Photo
        let transitionInfo: PhotoPreviewTransitionInfo
    }
    
    init(_ deps: Dependencies) {
        self.deps = deps
    }
    
    func build() -> UIViewController {
        let view = PhotoPreviewViewController()
        view.photo = self.deps.photo
        let transitionController = PhotoPreviewTransitionController(transitionInfo: self.deps.transitionInfo)
        view.transitionController = transitionController
        
        return view
    }
    
}
