//
//  FlickrSearchResponse.swift
//  VirtualTourist
//
//  Created by Huong Tran on 5/24/20.
//  Copyright © 2020 RiRiStudio. All rights reserved.
//

import Foundation

// MARK: - FlickrSearch
struct FlickrSearch: Codable {
    let photos: Photos
    let stat: String
}

// MARK: - Photos
struct Photos: Codable {
    let page, pages, perpage: Int
    let total: String
    let photo: [Photo]
}

// MARK: - Photo
struct Photo: Codable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let isPublic, isFriend, isFamily: Int
    
    enum CodingKeys: String, CodingKey {
        case id, owner, secret, server, farm, title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
    }
}
