//
//  ImageViewController.swift
//  ImageGallery
//
//  Created by john sanford on 8/12/19.
//  Copyright © 2019 Jack Sanford. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    var finalImage: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            // sets the content size for scrolling
            // otherwise scroll would not work in a (0,0) frame
            // question marks are so that these work in a prepare func
            scrollView?.contentSize = imageView.frame.size
//            spinner?.stopAnimating()
        }
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 1/25
            scrollView.maximumZoomScale = 3.0
            scrollView.delegate = self
            scrollView.addSubview(imageView)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    var imageView = UIImageView()

}
