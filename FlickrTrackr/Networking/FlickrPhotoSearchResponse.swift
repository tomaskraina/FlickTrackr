//
//  FlickrPhotoSearchResponse.swift
//  FlickrTrackr
//
//  Created by Tom Kraina on 21/09/2018.
//  Copyright © 2018 Tom Kraina. All rights reserved.
//

import Foundation

struct FlickrPhotoSearchResponse: Codable {

    let searchResult: FlickrSearchResult?
    let status: String
    let errorCode: Int?
    let errorMessage: String?
    
    private enum CodingKeys: String, CodingKey {
        case searchResult = "photos"
        case status = "stat"
        case errorCode = "code"
        case errorMessage = "message"
    }
}

struct FlickrSearchResult: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photos: [FlickrPhoto]
    
    private enum CodingKeys: String, CodingKey {
        case photos = "photo"
        case page, pages, perpage, total
    }
    
    init(from decoder: Decoder) throws {
        
        // We want custom decoding as the value for 'pages' key can be both String and Int
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        page = try values.decode(Int.self, forKey: .page)
        perpage = try values.decode(Int.self, forKey: .perpage)
        total = try values.decode(String.self, forKey: .total)
        photos = try values.decode([FlickrPhoto].self, forKey: .photos)
        
        do {
            pages = try values.decode(Int.self, forKey: .pages)
        } catch {
            let stringValue: String = try values.decode(String.self, forKey: .pages)
            pages = Int(stringValue) ?? -1
        }
    }
}
