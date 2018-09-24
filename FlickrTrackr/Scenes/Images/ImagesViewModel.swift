//
//  ImagesViewModel.swift
//  FlickrTrackr
//
//  Created by Tom Kraina on 21/09/2018.
//  Copyright © 2018 Tom Kraina. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation


// MARK: - Dependencies

protocol HasPersistentContainer {
    var persistentContainer: NSPersistentContainer { get }
}

protocol HasApiClient {
    var apiClient: FlickrApiClient { get }
}

protocol HasLocationTracker {
    var locationTracker: LocationTracker { get }
}

enum PhotoRequestStatus {
    case notYetRequesting
    case requestingPhotos
    case noPhotos
    case photosFound
}

// MARK: - ImagesViewModel

class ImagesViewModel {
    
    typealias Dependencies = HasPersistentContainer & HasApiClient & HasLocationTracker
    
    init(dependencies: Dependencies) {
        persistentContainer = dependencies.persistentContainer
        flickrApiClient = dependencies.apiClient
        locationTracker = dependencies.locationTracker
        
        // Needs to be done here because property setters are not called during init
        configure(locationTracker: locationTracker)
    }
    
    var persistentContainer: NSPersistentContainer
    
    var flickrApiClient: FlickrApiClient
    
    var locationTracker: LocationTracker {
        didSet {
            configure(locationTracker: locationTracker)
        }
    }
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var isTrackerRunning: Bool {
        return locationTracker.isRunning
    }
    
    var onStartStop: ((Bool) -> Void)? {
        didSet {
            onStartStop?(isTrackerRunning)
        }
    }
    
    var onAuthorizationInAppOnly: (() -> Void)?
    
    var onAuthorizationError: ((LocationTrackerError) -> Void)?
    
    func start() {
        do {
            locationTracker.requestAuthorization()
            try locationTracker.start()
            onStartStop?(isTrackerRunning)
            
        } catch let error as LocationTrackerError {
            onAuthorizationError?(error)
            
        } catch {
            fatalError("Unexpected error: \(error). 'requestLocationAuthorization' should never return any other error then LocationTrackerError")
        }
    }
    
    func stop() {
        locationTracker.stop()
        onStartStop?(isTrackerRunning)
    }
    
    func makeFetchResultsController(delegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<LocationManagedObject> {
        
        let fetchRequest: NSFetchRequest = LocationManagedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "timestamp != nil")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor.init(key: "timestamp", ascending: false),
            NSSortDescriptor.init(key: "createdDate", ascending: false),
        ]
        
        let controller = NSFetchedResultsController<LocationManagedObject>.init(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = delegate
        return controller
    }
    
    func deleteAllLocations() {
        let context = persistentContainer.newBackgroundContext()
        let request: NSFetchRequest = LocationManagedObject.fetchRequest()
        
        context.perform {
            do {
                let objects = try context.fetch(request)
                objects.forEach() {
                    context.delete($0)
                }
                
                try context.save()
                
            } catch {
                print("Error when deleting all locations:", error)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func configure(locationTracker: LocationTracker) {
        
        locationTracker.onAuthorizationUpdate = { [weak self] status in
            guard let self = self else { return }
            
            switch status {
            case .denied:
                self.stop()
                self.onAuthorizationError?(LocationTrackerError.AuthorizationStatusDenied)
            case .restricted:
                self.stop()
                self.onAuthorizationError?(LocationTrackerError.AuthorizationStatusRestricted)
            case .authorizedWhenInUse, .authorizedAlways:
                break // Both WhenInUser and Always are okay
            case .notDetermined:
                break // Authorization is yet to be requested
            }
        }
        
        locationTracker.onLocationUpdate = { [weak self] locations in
            guard let self = self else { return }
            self.storeLocations(locations)
        }
    }
    
    // MARK: - Locations
    
    private func storeLocations(_ locations: [CLLocation]) {
        let context = persistentContainer.newBackgroundContext()
        
        context.perform {
            locations.forEach() {
                _ = LocationManagedObject(location: $0, in: context)
            }
            
            do {
                try context.save()
                
            } catch {
                print("Error when storing locations:", error)
            }
        }
    }

    // MARK: - Photos
    
    private var objectIDsBeingRequested: Set<NSManagedObjectID> = Set()
    
    private var objectIDsWithNoPhotosFound: Set<NSManagedObjectID> = Set()
    
    func photoStatus(for objectID: NSManagedObjectID) -> PhotoRequestStatus {
        if objectIDsWithNoPhotosFound.contains(objectID) {
            return .noPhotos
        }
        
        if objectIDsBeingRequested.contains(objectID) {
            return .requestingPhotos
        }
        
        let object = viewContext.object(with: objectID) as? LocationManagedObject
        return object?.imageURL == nil ? .notYetRequesting : .photosFound
    }
    
    func recommendedSizeForView(size: CGSize) -> FlickrPhoto.Size {
        let realWidth = size.width * UIScreen.main.scale
        let realHeight = size.width * UIScreen.main.scale
        let longestSide = Int(ceil(max(realWidth, realHeight)))
        return FlickrPhoto.Size.from(longerSide: longestSide)
    }
    
    func requestPhotos(for coordinates: CLLocationCoordinate2D, objectID: NSManagedObjectID, size: FlickrPhoto.Size) {
        guard !objectIDsBeingRequested.contains(objectID) else {
            print("Skipping request. Photos are already being requested, objectID:", objectID)
            return
        }
        
        objectIDsWithNoPhotosFound.remove(objectID)
        objectIDsBeingRequested.insert(objectID)
        flickrApiClient.requestPhotos(forLocation: coordinates) { [weak self] result in
            self?.objectIDsBeingRequested.remove(objectID)
            
            if let error = result.error {
                print("Error during photo download:", error) // (e.g. no internet connection)
                return
            }
            
            guard let searchResult = result.value?.searchResult else {
                print("Search results not available, response:", result.value as Any)
                return
            }
            
            // Select a random photo from search result.
            // This is because Flickr often returns very the same set of photos
            // for similar locations and we want to show different photos on the timeline.
            guard let photo = self?.selectRandomPhoto(from: searchResult) else {
                print("No photo found for this location:", coordinates)
                self?.objectIDsWithNoPhotosFound.insert(objectID)
                return
            }
            
            self?.storePhoto(photo, in: objectID, size: size)
        }
    }
    
    private func storePhoto(_ photo: FlickrPhoto, in locationObjectID: NSManagedObjectID, size: FlickrPhoto.Size) {
        let context = persistentContainer.newBackgroundContext()
        context.perform {
            do {
                // We're not handling the case where the object could be deleted
                let object = context.object(with: locationObjectID)
                guard let locationObject = object as? LocationManagedObject else { return }
                
                guard locationObject.imageURL == nil else {
                    return // Don't update exisiting photos
                }
                
                let photoURL = photo.photoURL(for: size)
                locationObject.update(imageURL: photoURL, caption: photo.title)
                try context.save()
                
            } catch {
                print("Can't update photo url for locationObjectID:", locationObjectID)
                print(error)
            }
        }
    }
    
    private func selectRandomPhoto(from result: FlickrSearchResult) -> FlickrPhoto? {
        guard result.photos.count > 1 else {
            return result.photos.first
        }
        
        let randomIndex = Int.random(in: 0..<result.photos.count)
        return result.photos[randomIndex]
    }
}
