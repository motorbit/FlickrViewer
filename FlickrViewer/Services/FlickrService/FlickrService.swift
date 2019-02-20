//
//  FlickrService.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 Anton Makarov. All rights reserved.
//

import Foundation

final class FlickrService: FlickerServiceProtocol {
    static let shared = FlickrService()
    
    private init() {}
    
    func getRecent(_ page: Int, size: Int, completion: ((Result<RecentResponse>) -> Void)?)  {
        let extras = "date_upload,date_taken,owner_name,url_t,url_l,url_o,url_c"
        guard let request = FlickrRecentRequest(page: page, size: size, extras: extras).makeRequest() else { return }
        execute(request, completion: completion)
    }
    
    func search(_ text: String, page: Int, size: Int, completion: ((Result<RecentResponse>) -> Void)?)  {
        guard let request = FlickrSerchRequest(page: page, size: size, text: text)
            .makeRequest() else { return }
        execute(request, completion: completion)
    }
 
    private func execute(_ request: URLRequest, completion: ((Result<RecentResponse>) -> Void)?) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, error) in
            if let error = error {
                completion?(.failure(error))
            } else if let jsonData = responseData {
                do {
                    let recents = try JSONDecoder().decode(RecentResponse.self, from: jsonData)
                    completion?(.success(recents))
                } catch {
                    completion?(.failure(error))
                }
            } else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                completion?(.failure(error))
            }
        }
        task.resume()
    }
}










