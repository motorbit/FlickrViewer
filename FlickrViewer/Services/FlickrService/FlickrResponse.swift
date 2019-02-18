//
//  FlickrResponse.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/14/19.
//  Copyright © 2019 Anton Makarov. All rights reserved.
//

import Foundation

struct RecentResponse: Decodable {
    let photos: Photos
    let stat: String
    
    struct Photos: Decodable {
        let page: Int
        let pages: Int
        let perpage: Int
        let total: Total
        let photo: [Photo]
        
        struct Photo: Decodable {
            let id: String
            let owner: String
            let title: String
        }
    }
}

enum Total: Decodable {
    case integer(Int)
    case string(String)
    
    var intValue: Int? {
        switch self {
        case .integer(let int):
            return int
        case .string(let str):
            return Int(str)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(Total.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Total"))
    }
}
