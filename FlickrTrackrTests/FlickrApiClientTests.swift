//
//  FlickrApiClientTests.swift
//  FlickrTrackrTests
//
//  Created by Tom Kraina on 21/09/2018.
//  Copyright © 2018 Tom Kraina. All rights reserved.
//

import XCTest
@testable import FlickrTrackr
import CoreLocation

class FlickrApiClientTests: XCTestCase {

    func testRealPhotoSearch() {
        let prague = CLLocationCoordinate2D.init(latitude: 50.0593308, longitude: 14.1847631)
        let client = FlickrApiClient(apiKey: ApiKey(stringValue: FLICKR_API_KEY))
        
        // Smaller radius than 1km often produce no results
        client.searchRadius = Measurement(value: 750, unit: UnitLength.meters)
        
        let expectation = self.expectation(description: "Returned response")
        client.requestPhotos(forLocation: prague) { (result) in
            
            XCTAssertNil(result.error)
            XCTAssertGreaterThan(result.value?.searchResult?.photos.count ?? 0, 0)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testMakeURL() {
        let prague = CLLocationCoordinate2D.init(latitude: 50.0593308, longitude: 14.1847631)
        let client = FlickrApiClient(apiKey: ApiKey(stringValue: "fake-api-key"))
        let searchRadius = Measurement(value: 1, unit: UnitLength.kilometers)
        let url = client.makeSearchPhotosURL(apiKey: client.apiKey, coordinates: prague, searchRadius: searchRadius, limit: 30)
        
        XCTAssertEqual(url.absoluteString, "https://api.flickr.com/services/rest/?api_key=fake-api-key&format=json&lat=50.0593308&lon=14.1847631&method=flickr.photos.search&nojsoncallback=1&per_page=30&radius=1.0&radius_units=km")
    }
}
