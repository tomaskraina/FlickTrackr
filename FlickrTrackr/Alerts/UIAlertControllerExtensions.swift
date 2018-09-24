//
//  UIAlertControllerExtensions.swift
//  FlickrTrackr
//
//  Created by Tom Kraina on 23/09/2018.
//  Copyright © 2018 Tom Kraina. All rights reserved.
//

import Foundation
import UIKit

enum StopTrackingResult {
    case stopAndKeepData
    case stopAndDeleteData
}

extension UIAlertController {
    
    static func makeStopTrackingAlert(completion: @escaping ((StopTrackingResult) -> Void)) -> UIAlertController {
        let title = NSLocalizedString("tracker.dialog.title", comment: "Title on confirmation dialog to stop tracking.")
        let message = NSLocalizedString("tracker.dialog.message", comment: "Message on confirmation dialog to stop tracking.")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("tracker.dialog.cancel", comment: "Cancel button title on confirmation dialog to stop tracking."), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("tracker.dialog.stopAndKeep", comment: "'Stop and Keep' button title on confirmation dialog to stop tracking."), style: .default, handler: { _ in
            completion(.stopAndKeepData)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("tracker.dialog.stopAndDelete", comment: "'Stop and Delete' title on confirmation dialog to stop tracking."), style: .destructive, handler: { _ in
            completion(.stopAndDeleteData)
        }))
        
        return alert
    }

    static func makeAlert(error: LocationTrackerError) -> UIAlertController {
        
        let title = NSLocalizedString("tracker.error.title", comment: "Title on location error alert.")
        let message = [
            error.localizedDescription,
            error.recoverySuggestion
            ].compactMap{ $0 }
            .joined(separator: "\n\n")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("tracker.error.cancel", comment: "Cancel button title on location error alert."), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("tracker.error.settings", comment: "'Open settings' button title on location error alert."), style: .default, handler: { (_) in
            openAppSettings()
        }))
        
        return alert
    }
}

private func openAppSettings() {
    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
}
