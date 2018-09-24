//
//  FlickrApiClient.swift
//  FlickrTrackr
//
//  Created by Tom Kraina on 20/09/2018.
//  Copyright © 2018 Tom Kraina. All rights reserved.
//

import Foundation
import CoreLocation

/// Phantom type for storing API keys
struct ApiKey {
    let stringValue: String
}

class FlickrApiClient {
    
    init(apiKey: ApiKey) {
        self.apiKey = apiKey
    }
    
    let apiKey: ApiKey
    
    var networking = Networking.shared
    
    var searchRadius = Measurement(value: 1, unit: UnitLength.kilometers)
    
    @discardableResult
    func requestPhotos(forLocation coordinates: CLLocationCoordinate2D, completion: @escaping (Result<FlickrPhotoSearchResponse>) -> Void) -> URLSessionDataTask {
        
        let url = makeSearchPhotosURL(apiKey: apiKey, coordinates: coordinates, searchRadius: searchRadius, limit: 50)
        return networking.request(url: url, completion: completion)
    }
    
    func makeSearchPhotosURL(apiKey: ApiKey, coordinates: CLLocationCoordinate2D, searchRadius: Measurement<UnitLength>, limit: UInt) -> URL {
        
        let radiusInKm = searchRadius.converted(to: .kilometers).value
        
        let params: [String: String] = [
            "method": "flickr.photos.search",
            "api_key": apiKey.stringValue,
            "lat": String(coordinates.latitude),
            "lon": String(coordinates.longitude),
            "radius": String(radiusInKm),
            "per_page": String(limit),
            "radius_units": "km",
            "format": "json",
            "nojsoncallback": "1",
        ]
        
        let queryItems = params
            .map { URLQueryItem(name: $0.key, value: $0.value) }
            .sorted(by: { $0.name < $1.name }) // Sort it so it produces stable URL
        
        guard let urlComponents = URLComponents(string: "https://api.flickr.com/services/rest/") else {
            fatalError("Can't create URLComponents from provided string")
        }
        
        var components = urlComponents
        components.queryItems = (components.queryItems ?? []) + queryItems
        
        guard let url = components.url else {
            fatalError("Can't create URL from URLComponents: '\(components)'")
        }
        
        return url
    }
}

