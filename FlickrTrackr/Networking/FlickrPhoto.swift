//
//  FlickrPhoto.swift
//  FlickrTrackr
//
//  Created by Tom Kraina on 21/09/2018.
//  Copyright © 2018 Tom Kraina. All rights reserved.
//

import Foundation

struct FlickrPhoto: Codable {
    let id: String
    let secret: String
    let server: String
    let farm: Int
    let title: String?
}


extension FlickrPhoto {
    
    /// Flickr size classes used for creating photo source URLs
    /// More info: https://www.flickr.com/services/api/misc.urls.html
    ///
    /// - largeSquare:  q    large square 150x150
    /// - medium640:    z    medium 640, 640 on longest side
    /// - medium800:    c    medium 800, 800 on longest side†
    enum Size: String {
        
        // from https://www.flickr.com/services/api/misc.urls.html
        //        s    small square 75x75
        //        q    large square 150x150
        //        t    thumbnail, 100 on longest side
        //        m    small, 240 on longest side
        //        n    small, 320 on longest side
        //        -    medium, 500 on longest side
        //        z    medium 640, 640 on longest side
        //        c    medium 800, 800 on longest side†
        //        b    large, 1024 on longest side*
        //        h    large 1600, 1600 on longest side†
        //        k    large 2048, 2048 on longest side†
        //        o    original image, either a jpg, gif or png, depending on source format
        //        * Before May 25th 2010 large photos only exist for very large original images.
        //
        //        † Medium 800, large 1600, and large 2048 photos only exist after March 1st 2012.
        
        case largeSquare = "q"
        case small240 = "m"
        case small320 = "n"
        case medium500 = "-"
        case medium640 = "z"
        case medium800 = "c"
        case large1024 = "b"
        case large1600 = "h"
        case large2048 = "k"
    }
    
    
    /// Creates a photo source URL
    /// More info: https://www.flickr.com/services/api/misc.urls.html
    ///
    /// - Parameter size: photo size class
    /// - Returns: Photo source URL for provided size class
    func photoURL(for size: Size) -> URL {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_\(size.rawValue).jpg")!
    }
}

extension FlickrPhoto.Size {
    static func from(longerSide: Int) -> FlickrPhoto.Size {
        switch longerSide {
        case 0..<241:
            return .small240
        case 241..<321:
            return .small320
        case 321..<501:
            return .medium500
        case 501..<641:
            return .medium640
        case 641..<801:
            return .medium800
        case 801..<1025:
            return .large1024
        case 1025..<1601:
            return .large1600
        case ..<1601:
            return .large2048
            
        default:
            return .medium640
        }
    }
}
