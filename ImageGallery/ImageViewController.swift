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
            // question marks are so that these work in a prepare func
            scrollView?.contentSize = imageView.frame.size
            spinner?.stopAnimating()
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
    
    private func fetchImage() {
        // checking to see if URL is non-nil
        if let url = imageURL {
            spinner.startAnimating()
            // do weak self here because otherwise if you navigate away from
            // this viewController this code will still keep this VC in the heap
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let imageData = urlContents, url == self?.imageURL {
                        self?.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if imageURL == nil {
//            imageURL  = DemoURLs.berkeley
//        }
    }
    

}
