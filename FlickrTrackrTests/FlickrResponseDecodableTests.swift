//
//  FlickrResponseDecodableTests.swift
//  FlickrTrackrTests
//
//  Created by Tom Kraina on 20/09/2018.
//  Copyright © 2018 Tom Kraina. All rights reserved.
//

import XCTest
@testable import FlickrTrackr

class FlickrResponseDecodableTests: XCTestCase {

    func testDecodeFlickrPhotoSearchResponseSuccess() throws {
        let response: FlickrPhotoSearchResponse = try JSON(named: "flickr.photos.search-success")
        XCTAssertGreaterThan(response.searchResult?.photos.count ?? 0, 0)
    }
    
    func testDecodeFlickrPhotoSearchResponseError() throws {
        let response: FlickrPhotoSearchResponse = try JSON(named: "flickr.photos.search-error")
        XCTAssertNil(response.searchResult)
    }
    
    func testDecodeSearchResultWherePagesIsInt() throws {
        let json = """
            { "page": 1, "pages": 2, "perpage": 100, "total": "1170344", "photo": [] }
        """.data(using: .utf8)!
        let searchResult = try JSONDecoder().decode(FlickrSearchResult.self, from: json)
        XCTAssertEqual(searchResult.pages, 2)
    }
    
    func testDecodeSearchResultWherePagesIsString() throws {
        let json = """
            { "page": 1, "pages": "2", "perpage": 100, "total": "1170344", "photo": [] }
        """.data(using: .utf8)!
        let searchResult = try JSONDecoder().decode(FlickrSearchResult.self, from: json)
        XCTAssertEqual(searchResult.pages, 2)
    }

}
