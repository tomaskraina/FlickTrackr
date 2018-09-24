//
//  LocationTrackerError.swift
//  FlickrTrackr
//
//  Created by Tom Kraina on 20/09/2018.
//  Copyright © 2018 Tom Kraina. All rights reserved.
//

import Foundation

enum LocationTrackerError: Error {
    case LocationServicesNotAvailable
    case AuthorizationStatusDenied
    case AuthorizationStatusRestricted
}

// MARK: - LocationTrackerError+LocalizedError
extension LocationTrackerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .LocationServicesNotAvailable:
            return NSLocalizedString("LocationTrackerError.LocationServicesNotAvailable.description", comment: "Error description shown when location services are not available.")
        case .AuthorizationStatusDenied:
            return NSLocalizedString("LocationTrackerError.AuthorizationStatusDenied.description", comment: "Error description shown when location services are denied.")
        case .AuthorizationStatusRestricted:
            return NSLocalizedString("LocationTrackerError.AuthorizationStatusRestricted.description", comment: "Error description shown when location services are restricted.")
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .LocationServicesNotAvailable:
            return NSLocalizedString("LocationTrackerError.LocationServicesNotAvailable.recoverySuggestion", comment: "Error recovery suggestion shown when location services are not available.")
        case .AuthorizationStatusDenied:
            return NSLocalizedString("LocationTrackerError.AuthorizationStatusDenied.recoverySuggestion", comment: "Error recovery suggestion shown when location services are denied.")
        case .AuthorizationStatusRestricted:
            return NSLocalizedString("LocationTrackerError.AuthorizationStatusRestricted.recoverySuggestion", comment: "Error recovery suggestion shown when location services are restricted.")
        }
    }
}
