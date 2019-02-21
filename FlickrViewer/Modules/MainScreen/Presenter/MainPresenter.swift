//
//  SplashPresenter.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//

import UIKit

class MainPresenter: MainPresenterProtocol, MainInteractorOutput {
    
    weak var view: MainViewInput?
    var interactor: MainInteractorInput!
    var router: MainRouterProtocol!
 
    private var currentPage = 1
    private var pages = 0
    
    private var isRecent = true
    private var isNeedScroll = false
    private var searchText = "" {
        willSet {
            if searchText != newValue {
                isNeedScroll = true
                currentPage = 1
            }
        }
        didSet {
            self.isRecent = searchText.isEmpty
        }
    }
    
    func getData() {
        DispatchQueue.global(qos: .background).async { [unowned self] in
            if self.isRecent {
                self.interactor.getRecent(page: self.currentPage)
            } else {
                self.interactor.getSearch(text: self.searchText, page: self.currentPage)
            }
        }
    }
    
    func recentFetched(_ result: RecentResponse) {
        let total = result.photos.total.intValue ?? 0
        let photo = result.photos.photo.compactMap({ photo -> MainModel.Photo? in
            return ModelConverter.convert(photo: photo)
        })
        let model = MainModel(total: total, photos:photo, isNeedScroll: isNeedScroll)
        self.currentPage = result.photos.page
        self.pages = result.photos.pages
        isNeedScroll = false
        DispatchQueue.main.async { [unowned self] in
            self.view?.setup(model: model)
        }
    }
    
    func somethingWentWrong(_ error: Error) {
        DispatchQueue.main.async { [unowned self] in
            self.view?.showAlertOk(title: "Ooops", message: error.localizedDescription)
        }
    }

    func getNext() {
        let nextPage = currentPage + 1
        if nextPage <= pages {
            self.getData()
        }
    }
    
    func selected(photo: MainModel.Photo, imageView: UIImageView) {
        self.router.openPreview(photo: photo, imageView: imageView)
    }
    
    func search(_ text: String) {
        self.searchText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        self.getData()
    }
    
    func found(_ result: RecentResponse) {
        let total = result.photos.total.intValue ?? 0
        let photo = result.photos.photo.compactMap({ photo -> MainModel.Photo? in
            return ModelConverter.convert(photo: photo)
        })
        self.currentPage = result.photos.page
        let model = MainModel(total: total, photos:photo, isNeedScroll: isNeedScroll)
        self.pages = result.photos.pages
        isNeedScroll = false
        DispatchQueue.main.async { [unowned self] in
            self.view?.setup(model: model)
        }
    }
}




