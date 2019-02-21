//
//  FlickrRecentRequest.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/14/19.
//  Copyright © 2019 Anton Makarov. All rights reserved.
//

import Foundation

final class FlickrRecentRequest: FlickrRequest {
    init(page: Int = 1, size: Int = 10, extras: String? = nil) {
        super.init(method: .recent, page: page, size: size, extras: extras)
    }
}
