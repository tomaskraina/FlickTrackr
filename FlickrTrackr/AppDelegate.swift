//
//  AppDelegate.swift
//  FlickrTrackr
//
//  Created by Tom Kraina on 20/09/2018.
//  Copyright © 2018 Tom Kraina. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        guard let rootViewController = window?.rootViewController as? UINavigationController else {
            fatalError("Expected UINavigationController as rootViewController in app's window.")
        }
        
        guard let topViewController = rootViewController.topViewController as? ImagesViewController else {
            fatalError("Expected ImagesViewController as topViewController in UINavigationController.")
        }
        
        struct ImagesViewModelDependencies: ImagesViewModel.Dependencies {
            let apiClient: FlickrApiClient
            let locationTracker: LocationTracker
            let persistentContainer: NSPersistentContainer
        }
        
        // Here we could look for .location key in launchOptions and restart tracker if the app
        // was killed by the system while tracking but I didn't find it necessary
        let locationTracker = LocationTracker()
        let apiClient = FlickrApiClient(apiKey: ApiKey(stringValue: FLICKR_API_KEY))
        let dependencies = ImagesViewModelDependencies(apiClient: apiClient, locationTracker: locationTracker, persistentContainer: persistentContainer)
        let viewModel = ImagesViewModel(dependencies: dependencies)
        topViewController.viewModel = viewModel
        
        // Make sure changes on background contexts are merged into the main one
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        
        return true
    }
}

