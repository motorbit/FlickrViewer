//
//  SplashInteractor.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//

import Foundation

final class MainInteractor: MainInteractorInput {
    
    weak var presenter: MainInteractorOutput?
    private let flickrService: FlickerServiceProtocol!
    
    init(_ flickrService: FlickerServiceProtocol) {
        self.flickrService = flickrService
    }
    
    func fetchRecent(page: Int) {
        self.flickrService.getRecent(page, size: 50) { (result) in
            switch result {
            case .failure(let error):
                self.presenter?.somethingWentWrong(error)
            case .success(let value):
                self.presenter?.recentFetched(value)
            }
        }
    }
    
    func fetchSearch(text: String, page: Int) {
        self.flickrService.search(text, page: page, size: 50) { result in
            switch result {
            case .failure(let error):
                self.presenter?.somethingWentWrong(error)
            case .success(let value):
                self.presenter?.found(value)
            }
        }
    }
    
}
