//
//  ImageTableViewCell.swift
//  FlickrTrackr
//
//  Created by Tom Kraina on 20/09/2018.
//  Copyright © 2018 Tom Kraina. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    class var reusableIdentifier: String {
        return "ImageTableViewCell"
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var debugLabel: UILabel!
    
    // MARK: - UITableViewCell lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        mainImageView.moa.url = nil
        mainImageView.image = nil
        debugLabel.text = nil
    }

}
