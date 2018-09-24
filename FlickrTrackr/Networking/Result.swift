//
//  Result.swift
//  FlickrTrackr
//
//  Created by Tom Kraina on 21/09/2018.
//  Copyright © 2018 Tom Kraina. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(value: T)
    case failure(error: Error)
}

extension Result {
    var value: T? {
        guard case let Result.success(value) = self else { return nil }
        return value
    }
    
    var error: Error? {
        guard case let Result.failure(error) = self else { return nil }
        return error
    }
}
