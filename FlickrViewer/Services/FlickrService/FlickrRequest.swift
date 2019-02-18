//
//  FlickrRequest.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/14/19.
//  Copyright © 2019 Anton Makarov. All rights reserved.
//

import Foundation

enum Requests: String {
    case recent = "flickr.photos.getRecent"
    case search = "flickr.photos.search"
}

class FlickrRequest {
    private let size: Int
    private let page: Int
    private let extras: String?
    private let method: String
    
    init(method: Requests, page: Int = 1, size: Int = 10, extras: String? = nil) {
        self.size = size
        self.page = page
        self.extras = extras
        self.method = method.rawValue
    }
    
    func makeRequest() -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = ThirdPartyServicesFactory.flickr.scheme
        urlComponents.host = ThirdPartyServicesFactory.flickr.host
        urlComponents.path = ThirdPartyServicesFactory.flickr.path
        urlComponents.queryItems = getQueryItems()
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
    
    func getQueryItems() -> [URLQueryItem] {
        var result = [URLQueryItem]()
        result.append(URLQueryItem(name: "method", value: method))
        result.append(URLQueryItem(name: "api_key", value: ThirdPartyServicesFactory.flickr.key))
        result.append(URLQueryItem(name: "per_page", value: "\(size)"))
        result.append(URLQueryItem(name: "page", value: "\(page)"))
        result.append(URLQueryItem(name: "format", value: "json"))
        if let _extras = extras {
            result.append(URLQueryItem(name: "extras", value: _extras))
        }
        result.append(URLQueryItem(name: "nojsoncallback", value: "1"))
        return result
    }
}
