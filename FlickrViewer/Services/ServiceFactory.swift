//
//  ServiceFactory.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/19/19.
//  Copyright © 2019 Anton Makarov. All rights reserved.
//

import Foundation

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

protocol FlickerServiceProtocol {
    func getRecent(_ page: Int,
                   size: Int,
                   completion: ((Result<RecentResponse>) -> Void)?)
    
    func search(_ text: String,
                page: Int, size: Int,
                completion: ((Result<RecentResponse>) -> Void)?)
}

class ServiceFactory {
    func makeFlickerService() -> FlickerServiceProtocol {
        return FlickrService.shared
    }
}
