//
//  ImagesViewController.swift
//  FlickrTrackr
//
//  Created by Tom Kraina on 20/09/2018.
//  Copyright © 2018 Tom Kraina. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class ImagesViewController: UITableViewController {

    // MARK: - Configuration
    
    var viewModel: ImagesViewModel! {
        didSet {
            guard isViewLoaded else { return }
            setupBinding(viewModel)
        }
    }
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var startStopButton: UIBarButtonItem!
    
    // MARK: - IBAction
    
    @IBAction func startStopButtonTapped() {
        guard let viewModel = viewModel else { return }
        
        if viewModel.isTrackerRunning {
            let alert = UIAlertController.makeStopTrackingAlert() { [weak self] result in
                switch result {
                case .stopAndDeleteData:
                    self?.viewModel.stop()
                    self?.viewModel.deleteAllLocations()
                case .stopAndKeepData:
                    self?.viewModel.stop()
                }
            }
            present(alert, animated: true, completion: nil)
            
        } else {
            viewModel.start()
        }
    }
    
    // MARK: - UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.register(UINib.init(nibName: "ImageTableViewCell", bundle: nil), forCellReuseIdentifier: ImageTableViewCell.reusableIdentifier)
        setupBinding(viewModel)
    }

    // MARK: - Helpers

    private func updateStartStopButtonTitle() {
        startStopButton.title = viewModel.isTrackerRunning ?
            NSLocalizedString("tracker.button.stop", comment: "Title of tracker button when running") :
            NSLocalizedString("tracker.button.start", comment: "Title of tracker button when stopped")
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<LocationManagedObject> = { [unowned self] in
        let controller = self.viewModel.makeFetchResultsController(delegate: self)
        
        do {
            try controller.performFetch()
        } catch {
            print(error)
            fatalError("Can't performFetch on NSFetchedResultsController.")
        }
        
        return controller
    }()
    
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        formatter.locale = Locale.autoupdatingCurrent
        return formatter
    }()
    
    // MARK: - Binding
   
    private func setupBinding(_ viewModel: ImagesViewModel) {
        viewModel.onStartStop = { [weak self] _ in
            self?.updateStartStopButtonTitle()
        }
        
        viewModel.onAuthorizationError = { [weak self] error in
            guard let self = self else { return }
            let alert = UIAlertController.makeAlert(error: error)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - ImagesViewController+NSFetchedResultsControllerDelegate
extension ImagesViewController: NSFetchedResultsControllerDelegate {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.reusableIdentifier, for: indexPath)
        
        guard let imageCell = cell as? ImageTableViewCell else {
            fatalError("Expected ImageTableViewCell")
        }
        
        let location = fetchedResultsController.object(at: indexPath)
        configureCell(imageCell, withLocation: location)
        return cell
    }

    
    func configureCell(_ cell: ImageTableViewCell, withLocation location: LocationManagedObject) {
        
        // uncomment the following lines to show debug information on cells
//        let text = [
//            location.timestamp.flatMap({ self.formatter.string(from: $0) }) ?? "no date",
//            "latitude: " + String(location.coordinates.latitude),
//            "longitude: " + String(location.coordinates.longitude),
//            location.imageURL?.absoluteString ?? "no image URL",
//            location.imageCaption ?? "no image caption"
//            ].joined(separator: "\n")
//        cell.debugLabel.text = text
//        cell.debugLabel.isHidden = false
        
        let statusText: String? = {
            switch viewModel.photoStatus(for: location.objectID) {
            case .photosFound:
                return NSLocalizedString("photo.status.loadingPhoto", comment: "Status label when loading photos.")
            case .noPhotos:
                return NSLocalizedString("photo.status.noPhotoFound", comment: "Status label when no photos found for location.")
            case .requestingPhotos, .notYetRequesting:
                return NSLocalizedString("photo.status.requestingPhoto", comment: "Status label when requesting photos.")
            }
        }()
        cell.statusLabel.text = statusText
        
        // We should handle an error state here and display a retry button
        // when request for flickr photos fails (e.g. no internet connection)
        // but we're going to ignore it for now for the sake
        
        if let urlString = location.imageURL?.absoluteString {
            cell.mainImageView.moa.url = urlString
            cell.mainImageView.accessibilityLabel = location.imageCaption
            
        } else {
            cell.mainImageView.moa.url = nil
            let size = viewModel.recommendedSizeForView(size: cell.mainImageView.frame.size)
            viewModel?.requestPhotos(for: location.coordinates, objectID: location.objectID, size: size)
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            if let cell = tableView.cellForRow(at: indexPath!) as? ImageTableViewCell {
                configureCell(cell, withLocation: anObject as! LocationManagedObject)
            }
        case .move:
            if let cell = tableView.cellForRow(at: indexPath!) as? ImageTableViewCell {
                configureCell(cell, withLocation: anObject as! LocationManagedObject)
            }
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}


