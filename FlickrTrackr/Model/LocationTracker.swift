//
//  LocationTracker.swift
//  FlickrTrackr
//
//  Created by Tom Kraina on 20/09/2018.
//  Copyright © 2018 Tom Kraina. All rights reserved.
//

import Foundation
import CoreLocation

class LocationTracker: NSObject {
    
    var onLocationUpdate: (([CLLocation]) -> Void)?
    var onError: ((Error) -> Void)?
    
    var distanceThreshold = Measurement(value: 100, unit: UnitLength.meters) {
        didSet {
            locationManager.distanceFilter = distanceThreshold.converted(to: .meters).value
        }
    }
    
    private(set) var isRunning: Bool = false
    
    var currentAuthorization: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    var onAuthorizationUpdate: ((CLAuthorizationStatus) -> Void)?
    
    func requestAuthorization() {
        // When started in the foreground, services continue to run in the background if your app has enabled background location updates in the Capabilities tab of your Xcode project. Attempts to start location services while your app is running in the background will fail. The system displays a location-services indicator in the status bar when your app moves to the background with active location services.
        locationManager.requestWhenInUseAuthorization()
    }
    
    func start() throws {
        guard CLLocationManager.locationServicesEnabled() else {
            throw LocationTrackerError.LocationServicesNotAvailable
        }
        
        guard CLLocationManager.authorizationStatus() != .restricted else {
            throw LocationTrackerError.AuthorizationStatusRestricted
        }
        
        guard CLLocationManager.authorizationStatus() != .denied else {
            throw LocationTrackerError.AuthorizationStatusDenied
        }
        
        isRunning = true
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        isRunning = false
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Privates
    
    private lazy var locationManager: CLLocationManager = { [unowned self] in
        let manager = CLLocationManager()
        manager.activityType = .fitness
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = distanceThreshold.converted(to: .meters).value
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.showsBackgroundLocationIndicator = true
        manager.delegate = self
        return manager
    }()
}

// MARK: - LocationTracker+CLLocationManagerDelegate
extension LocationTracker: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        onLocationUpdate?(locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        onError?(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        onAuthorizationUpdate?(status)
    }
}
