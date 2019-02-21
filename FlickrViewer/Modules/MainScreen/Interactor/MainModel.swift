//
//  MainModel.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/21/19.
//  Copyright © 2019 Anton Makarov. All rights reserved.
//

import UIKit

struct MainModel {
    var total: Int
    var photos: [Photo]
    var isNeedScroll: Bool
    
    struct Photo {
        let title: String
        let thumb: Img?
        let uploaded: Date?
        let taken: Date?
        let owner: String
        let orig: Img?
    }
    
    struct Img {
        let url: String
        let size: CGSize
    }
}
