//
//  SplashProtocols.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//


import UIKit

protocol MainRouterProtocol: class {
    func openPreview(photo: MainModel.Photo, imageView: UIImageView)
}

protocol MainViewInput: class {
    func setup(model: MainModel)
    func showAlertOk(title: String, message: String)
}

protocol MainPresenterProtocol: class {
    func getData()
    func getNext()
    func selected(photo: MainModel.Photo, imageView: UIImageView)
    func search(_ text: String) 
}

protocol MainInteractorOutput: class {
    func recentFetched(_ result: RecentResponse)
    func found(_ result: RecentResponse)
    func somethingWentWrong(_ error: Error)
}

protocol MainInteractorInput: class {
    func getRecent(page: Int)
    func getSearch(text: String, page: Int)
}

