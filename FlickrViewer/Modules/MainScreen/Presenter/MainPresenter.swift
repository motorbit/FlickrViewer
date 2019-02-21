//
//  SplashPresenter.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//

import UIKit

final class MainPresenter: MainPresenterProtocol, MainInteractorOutput {
    
    // MARK: Public properties
    
    weak var view: MainViewInput?
    var interactor: MainInteractorInput!
    var router: MainRouterProtocol!
 
    // MARK: Private properties
    
    private var currentPage = 1
    private var pages = 0
    private var lastRequestedPage = 1
    
    private var isRecent = true
    private var isNeedScroll = false
    private var searchText = "" {
        didSet {
            self.isRecent = searchText.isEmpty
        }
    }
    
    // MARK: MainPresenter Protocol
    
    func fetchData() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            if self.isRecent {
                self.interactor.fetchRecent(page: self.lastRequestedPage)
            } else {
                self.interactor.fetchSearch(text: self.searchText, page: self.lastRequestedPage)
            }
        }
    }
    
    func search(_ text: String) {
        let _text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if _text != self.searchText {
            self.searchText = _text
            self.isNeedScroll = true
            self.currentPage = 1
            self.lastRequestedPage = 1
            self.fetchData()
        }
    }
    
    func fetchMore() {
        let nextPage = currentPage + 1
        if pages >= nextPage, nextPage > lastRequestedPage {
            lastRequestedPage = nextPage
            self.fetchData()
        }
    }
    
    func selected(photo: MainModel.Photo, imageView: UIImageView) {
        self.router.openPreview(photo: photo, imageView: imageView)
    }
    
    // MARK: MainInteractor Output
    
    func recentFetched(_ result: RecentResponse) {
        let total = result.photos.total.intValue ?? 0
        let photo = result.photos.photo.compactMap({ photo -> MainModel.Photo? in
            return ModelConverter.convert(photo: photo)
        })
        let model = MainModel(total: total, photos:photo, isNeedScroll: isNeedScroll)
        self.currentPage = result.photos.page
        self.pages = result.photos.pages
        isNeedScroll = false
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view?.setup(model: model)
        }
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view?.setup(model: model)
        }
    }
    
    func somethingWentWrong(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view?.showAlertOk(title: "Ooops", message: error.localizedDescription)
        }
    }
    
}




