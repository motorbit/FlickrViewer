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
        let total: FlickrMagicValue
        let photo: [Photo]
        
        struct Photo: Decodable {
            let title: String
            let dateupload: String
            let datetaken: String
            let ownername: String
            let url_t: String?
            let height_t: FlickrMagicValue?
            let width_t: FlickrMagicValue?
            let url_l: String?
            let height_l: FlickrMagicValue?
            let width_l: FlickrMagicValue?
            let url_o: String?
            let height_o: FlickrMagicValue?
            let width_o: FlickrMagicValue?
            let url_c: String?
            let height_c: FlickrMagicValue?
            let width_c: FlickrMagicValue?
        }
    }
}

enum FlickrMagicValue: Decodable {
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
        throw DecodingError.typeMismatch(FlickrMagicValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type"))
    }
}
