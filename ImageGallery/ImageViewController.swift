//
//  ImageViewController.swift
//  ImageGallery
//
//  Created by john sanford on 8/12/19.
//  Copyright © 2019 Jack Sanford. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    var imageURL: URL? {
        didSet {
            image = nil
            
            // way of checking that the view is onscreen
            if view.window != nil {
                fetchImage()
            }
            
        }
    }
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            // sets the content size for scrolling
            // otherwise scroll would not work in a (0,0) frame
            scrollView.contentSize = imageView.frame.size
        }
    }
    
    // when the window does come onscreen
    // want to load the image
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if imageView.image == nil {
            fetchImage()
        }
    }

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
    
    private func fetchImage() {
        // checking to see if URL is non-nil
        if let url = imageURL {
            let urlContents = try? Data(contentsOf: url)
            if let imageData = urlContents {
                image = UIImage(data: imageData)
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if imageURL == nil {
            imageURL  = DemoURLs.berkeley
        }
    }
    

}
