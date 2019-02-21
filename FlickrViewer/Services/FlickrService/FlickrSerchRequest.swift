//
//  FlickrSerchRequest.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/14/19.
//  Copyright © 2019 Anton Makarov. All rights reserved.
//

import Foundation

final class FlickrSerchRequest: FlickrRequest {
    var text: String
    
    init(page: Int = 1, size: Int = 10, extras: String? = nil, text: String) {
        self.text = text
        super.init(method: .search, page: page, size: size, extras: extras)
    }
    
    override func getQueryItems() -> [URLQueryItem] {
        var items = super.getQueryItems()
        items.append(URLQueryItem(name: "text", value: text))
        return items
    }
}
