//
//  ThirdPartyService.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 Anton Makarov. All rights reserved.
//

import Foundation

struct ThirdPartyServicesFactory {
    static let flickr: FlickerConfig = FlickerConfig(key: "1c68efee914ee87f4f9446fcc2211d70",
                                                     secret: "b9ce9a782158df8c",
                                                     scheme: "https",
                                                     host: "api.flickr.com",
                                                     path: "/services/rest/")
}

struct FlickerConfig {
    let key: String
    let secret: String
    let scheme: String
    let host: String
    let path: String
}
