//
//  ImageTableViewCell.swift
//  Smashtag
//
//  Created by Augusto on 12/28/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit


class ImageTableViewCell: UITableViewCell {
    @IBOutlet weak var pictureView: UIImageView!

    var pictureURL: URL? {
        didSet {
            fetchImage()
        }
    }
    
    fileprivate func fetchImage() {
        if let url = pictureURL {
            pictureView.image = nil
            let queue = DispatchQueue(label: "image fetcher", qos: .userInitiated)
            queue.async { [weak weakSelf = self] in
                do {
                    let contentsOfURL = try Data(contentsOf: url)
                    let image = UIImage(data: contentsOfURL)!
                    DispatchQueue.main.async {
                        if url == self.pictureURL {
                            weakSelf?.pictureView.image = image
                            weakSelf?.setNeedsLayout()
                            print("loaded")
                        }
                    }
                } catch let exception {
                    print(exception.localizedDescription)
                }
            }
        }
    }
    
    fileprivate func resize(image: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: (pictureView?.bounds.width)!, height: (pictureView?.bounds.height)!))
        image.draw(in: (pictureView?.bounds)!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
