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
 
    func showed() {
        DispatchQueue.global(qos: .background).async { [unowned self] in
            self.interactor.getRecent(page: 1)
        }
    }
    
    func recentFetched(_ result: RecentResponse) {
        DispatchQueue.main.async { [unowned self] in
            let total = result.photos.total.intValue ?? 0
            let photo =  result.photos.photo.map( { photo -> MainModel.Photo in
                return MainPresenter.convert(photo: photo)
            })
            let model = MainModel(total: total, photos:photo)
            self.view?.setup(model: model)
        }
    }
    
    func somethingWentWrong(_ error: Error) {
        DispatchQueue.main.async { [unowned self] in
            print(error)
        }
    }
    
    
    private static func convert(photo: RecentResponse.Photos.Photo) -> MainModel.Photo {
        let thumb = MainModel.Img(url: photo.url_t, size: CGSize(width: Int(photo.width_t)!, height: Int(photo.height_t)!))
        
        return MainModel.Photo(title: photo.title,
                               thumb: thumb,
                               uploaded: Date(),
                               taken: Date(),
                               owner: photo.ownername,
                               orig: thumb)
        
    }
    
}




