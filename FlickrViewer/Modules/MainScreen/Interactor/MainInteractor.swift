//
//  SplashInteractor.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//

import Foundation

class MainInteractor: MainInteractorInput {
    
    weak var presenter: MainInteractorOutput?
    private let flickrService: FlickerServiceProtocol!
    
    init(_ flickrService: FlickerServiceProtocol) {
        self.flickrService = flickrService
    }
    
    func getRecent(page: Int) {
        self.flickrService.getRecent(page, size: 30) { (result) in
            switch result {
            case .failure(let error):
                self.presenter?.somethingWentWrong(error)
            case .success(let value):
                self.presenter?.recentFetched(value)
            }
        }
    }
    
}
