//
//  helpers.swift
//  FlickrTrackrTests
//
//  Created by Tom Kraina on 20/09/2018.
//  Copyright © 2018 Tom Kraina. All rights reserved.
//

import Foundation

private class _FlickrTrackrTests: NSObject {}

let FlickrTrackrTestsBundle = Bundle(for: _FlickrTrackrTests.self)

func JSON<T: Decodable>(named name: String) throws -> T {
    let url = FlickrTrackrTestsBundle.url(forResource: name, withExtension: "json")!
    let data = try Data(contentsOf: url)
    do {
        return try JSONDecoder().decode(T.self, from: data)
    } catch {
        print(error)
        throw error
    }
}

