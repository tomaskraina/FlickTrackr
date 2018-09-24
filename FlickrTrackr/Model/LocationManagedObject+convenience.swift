//
//  LocationManagedObject+convenience.swift
//  FlickrTrackr
//
//  Created by Tom Kraina on 20/09/2018.
//  Copyright © 2018 Tom Kraina. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation

public extension LocationManagedObject {
    
    var coordinates: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
    public convenience init(coordinates: CLLocationCoordinate2D, in context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.coordinates = coordinates
        self.timestamp = Date()
        self.createdDate = Date()
    }
    
    public convenience init(location: CLLocation, in context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.coordinates = location.coordinate
        self.timestamp = location.timestamp
        self.createdDate = Date()
    }
    
    public func update(imageURL: URL, caption: String?) {
        self.imageURL = imageURL
        self.imageCaption = caption
    }
}
