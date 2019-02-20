//
//  ModelConverter.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/20/19.
//  Copyright © 2019 Anton Makarov. All rights reserved.
//

import UIKit

class ModelConverter {
    
    static func convert(photo: RecentResponse.Photos.Photo) -> MainModel.Photo? {
        guard let thumb = getThumb(photo: photo),
            let origin = getOriginImage(photo: photo) else { return nil }
        
        return MainModel.Photo(title: photo.title,
                               thumb: thumb,
                               uploaded: Date(),
                               taken: Date(),
                               owner: photo.ownername,
                               orig: origin)
    }
    
    private static func getOriginImage(photo: RecentResponse.Photos.Photo) -> MainModel.Img? {
        //o>>l>>c>>t
        
        if let url = photo.url_o,
            let width = photo.width_o?.intValue,
            let height = photo.height_o?.intValue {
            let size = CGSize(width: width, height: height)
            return MainModel.Img(url: url, size: size)
        }
        if let url = photo.url_l,
            let width = photo.width_l?.intValue,
            let height = photo.height_l?.intValue {
            let size = CGSize(width: width, height: height)
            return MainModel.Img(url: url, size: size)
        }
        if let url = photo.url_c,
            let width = photo.width_c?.intValue,
            let height = photo.height_c?.intValue {
            let size = CGSize(width: width, height: height)
            return MainModel.Img(url: url, size: size)
        }
        if let thumb = getThumb(photo: photo) {
            return thumb
        }
        return nil
    }
    
    private static func getThumb(photo: RecentResponse.Photos.Photo) -> MainModel.Img? {
        if let url = photo.url_t,
            let width = photo.width_t?.intValue,
            let height = photo.height_t?.intValue {
            let size = CGSize(width: width, height: height)
            return MainModel.Img(url: url, size: size)
        }
        return nil
    }
}
