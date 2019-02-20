//
//  SplashPresenter.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//

import Foundation

class MainPresenter: MainPresenterProtocol, MainInteractorOutput {
    
    weak var view: MainViewInput?
    var interactor: MainInteractorInput!
    var router: MainRouterProtocol!
 
    private var currentPage = 1
    private var pages = 0
    private var requestedNewData = false
    
    func showed() {
        requestedNewData = true
        DispatchQueue.global(qos: .background).async { [unowned self] in
            self.interactor.getRecent(page: self.currentPage)
        }
    }
    
    func recentFetched(_ result: RecentResponse) {
        requestedNewData = false
        let total = result.photos.total.intValue ?? 0
        let photo = result.photos.photo.compactMap({ photo -> MainModel.Photo? in
            return ModelConverter.convert(photo: photo)
        })
        let model = MainModel(total: total, photos:photo)
        self.currentPage = result.photos.page
        self.pages = result.photos.pages
        
        DispatchQueue.main.async { [unowned self] in
            self.view?.setup(model: model)
        }
    }
    
    func somethingWentWrong(_ error: Error) {
        requestedNewData = false
        DispatchQueue.main.async { [unowned self] in
            print(error)
        }
    }
    
    func getNext() {
        let nextPage = currentPage + 1
        if !requestedNewData, nextPage <= pages {
            requestedNewData = true
            DispatchQueue.global(qos: .background).async { [unowned self] in
                self.interactor.getRecent(page: nextPage)
            }
        }
    }
    
    func selected(photo: MainModel.Photo) {
        self.router.openPreview(photo: photo)
    }
}




