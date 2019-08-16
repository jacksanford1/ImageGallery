//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by john sanford on 8/14/19.
//  Copyright © 2019 Jack Sanford. All rights reserved.
//

import UIKit

private let reuseIdentifier = "collectionCell"

class ImageGalleryCollectionViewController: UICollectionViewController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("segue.identifier is \(String(describing: segue.identifier))")
//        print("segue.destination is \(segue.destination)")
        var destination = segue.destination
        if let navcon = destination as? UINavigationController {
            destination = navcon.visibleViewController ?? navcon
        }
        if let imageVC = destination as? ImageViewController {
            if let senderCell = sender as? IGCollectionViewCell {
                imageVC.finalImage = senderCell.imageView.image
            }
        }
    }
    
    var imageView = UIImageView()
    
//    var selectedImage: UIImage?
    
    var currentArtist: [URL]? {
        didSet {
//            print("currentArtist got set")
            fetchCurrentArtistImages()
        }
    }
    
    var loadedImages = [UIImage]()
    
    private var image: UIImage? {
        get {
//            print("image's get is called")
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
//            print("image is set as \(String(describing: image))")
        }
    }
    
    private func fetchCurrentArtistImages() {
//        print("fetchCurrentArtistImages ran!")
        for URL in currentArtist! {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: URL)
                DispatchQueue.main.async {
                    if let imageData = urlContents {
                        if let loadedImage = UIImage(data: imageData) {
                            self?.loadedImages.append(loadedImage)
                            self?.collectionView.reloadData()
//                            self?.addTapGestures()
                        }
                    }
                }
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentArtist?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! IGCollectionViewCell
        //        print("collectionView cellForItemAt func is called!")
        
        // Configure the cell
//        print("imageURL starts out as \(String(describing: imageURL))")
        cell.spinner.startAnimating()
        if indexPath.item + 1 <= loadedImages.count {
            image = loadedImages[indexPath.item]
            cell.imageView.image = image
            cell.spinner.stopAnimating()
//            print("image is \(String(describing: image))")
        }
        return cell
    }

    // MARK: UICollectionViewDelegate
    
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
////        print("didSelectItemAt gets called at \(indexPath.item)")
//        selectedImage = loadedImages[indexPath.item]
//        print("selectedImage is \(String(describing: selectedImage))")
//        // do stuff with image, or with other data that you need
//    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
