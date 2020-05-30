//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Huong Tran on 5/24/20.
//  Copyright © 2020 RiRiStudio. All rights reserved.
//

import Foundation

class FlickrClient {
    static let apiKey = "1057775ac9438fd337664a0a49102c08"
    enum Endpoints {
        static let base = "https://www.flickr.com/services/rest/"
        
        case getPhotoURLs(Double, Double, Int)
        case photoURL(Int, String, String, String)
        
        var stringValue: String {
            switch self {
            case .getPhotoURLs(let lat, let lon, let page):
                return Endpoints.base + "?method=flickr.photos.search&api_key=\(FlickrClient.apiKey)&lat=\(lat)&lon=\(lon)&per_page=50&page=\(page)&format=json&nojsoncallback=1"
            case .photoURL(let farmId, let serverId, let id, let secret):
                return "https://farm\(farmId).staticflickr.com/\(serverId)/\(id)_\(secret).jpg"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
//    func getImageURL(farmId: String, serverId: String, id: String, secret: String) -> URL {
//        return URL(string: "https://farm\(farmId).staticflickr.com/\(serverId)/\(id)_\(secret).jpg")!
//    }
    
    @discardableResult class func taskForGETRequest<ResponseType: Codable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void ) -> URLSessionTask {
        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
//                do {
//                    let errorResponse = try decoder.decode(TMDBResopnse.self, from: data)
//                    DispatchQueue.main.async {
//                        completion(nil, errorResponse)
//                    }
//                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
//                }
            }
        }
        task.resume()
        return task
    }
    
    class func downloadPhoto(farmId: Int, serverId: String, id: String, secret: String, completion: @escaping (Data?, Error?) -> Void) {
//        print(Endpoints.photoURL(farmId, serverId, id, secret).url)
        let task = URLSession.shared.dataTask(with: Endpoints.photoURL(farmId, serverId, id, secret).url) { data, response, error in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
        task.resume()
    }
    
    class func getPhotoURLs(lat: Double, lon: Double, completion: @escaping (FlickrSearch?, Error?) -> Void) {
        let randomPage = Int.random(in: 1..<10)
        taskForGETRequest(url: Endpoints.getPhotoURLs(lat, lon, randomPage).url, response: FlickrSearch.self) {
            (response, error) in
            if let response = response {
                completion(response, nil)
                
            } else {
                completion(nil, error)
            }
        }
    }
}
