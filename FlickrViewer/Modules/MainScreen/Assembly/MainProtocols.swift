//
//  SplashProtocols.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//


import UIKit

protocol MainRouterProtocol: class {
    func openPreview(photo: MainModel.Photo)
}

protocol MainViewInput: class {
    func setup(model: MainModel)
}

protocol MainPresenterProtocol: class {
    func showed()
    func getNext()
    func selected(photo: MainModel.Photo)
}

protocol MainInteractorOutput: class {
    func recentFetched(_ result: RecentResponse)
    func somethingWentWrong(_ error: Error)
}

protocol MainInteractorInput: class {
    func getRecent(page: Int)
}

