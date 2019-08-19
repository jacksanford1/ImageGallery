//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by john sanford on 8/14/19.
//  Copyright © 2019 Jack Sanford. All rights reserved.
//

import UIKit

private let reuseIdentifier = "collectionCell"

// Add empty arrays up here and create a function that converts url strings into urls?

class ImageGalleryCollectionViewController: UICollectionViewController, UIGestureRecognizerDelegate, UIDropInteractionDelegate, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
    }
    
    // MARK: Update Model
    
    var ImageGalleryTableViewController: ImageGalleryTableViewController?
    
    func addDroppedURL(of url: URL, artist: String) {
        ImageGalleryTableViewController?.addURL(for: url, artist: artist)
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
    
    // MARK: - Maximum Collection View Item Width
    
    private var maximumItemWidth: CGFloat? {
        return collectionView?.frame.size.width
    }
    
    // MARK: - Minimum Collection View Item Width
    
    private var minimumItemWidth: CGFloat? {
        guard let collectionView = collectionView else {return nil}
        return (collectionView.frame.size.width / 2) - 5
    }
    
    // MARK: - Width of each cell in collection view
    
    private lazy var itemWidth: CGFloat = {
        return minimumItemWidth ?? 0
    }()
    
    // MARK: - Collection View's Flow Layout
    
    private var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    // MARK: - Pinch Gesture for Collection View Cell
    
    @IBAction func pinchGesture(_ sender: UIPinchGestureRecognizer) {
        guard let maximumItemWidth = maximumItemWidth else {return}
        guard let minimumItemWidth = minimumItemWidth else {return}
        guard itemWidth <= maximumItemWidth else {return}
        
        if sender.state == .began || sender.state == .changed {
            let scaledWidth = itemWidth * sender.scale
            
            if scaledWidth <= maximumItemWidth,
                scaledWidth >= minimumItemWidth {
                itemWidth = scaledWidth
                flowLayout?.invalidateLayout()
            }
            sender.scale = 1
        }
        
    }
    
    // MARK: - Flow Layout Delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Calculate the image's height based on calc'd aspect ratio
        if let loadedImage = loadedImages[indexPath.item] {
            let imageHeight = loadedImage.size.height
            let imageWidth = loadedImage.size.width
            let imageAspectRatio = (imageWidth/imageHeight)
            let scaledImageHeight = itemWidth / imageAspectRatio
            if scaledImageHeight >= ((collectionView.frame.size.height / 2) - 5) {
                return CGSize(width: itemWidth, height: scaledImageHeight)
            }
        }
        // Otherwise just set height to same as item width (1:1 aspect ratio)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    // MARK: LoadView to set Flow Layout
    
    override func loadView() {
        super.loadView()
        
//        flowLayout?.minimumLineSpacing = 5
//        flowLayout?.minimumInteritemSpacing = 5
    }
    
    // MARK: - Drag Items
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }

    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let dragImage = (collectionView.cellForItem(at: indexPath) as? IGCollectionViewCell)?.imageView.image {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: dragImage))
            dragItem.localObject = dragImage
            return [dragItem]
        } else {
            return []
        }
    }
    
    // MARK: - Drop Items
    
    @IBOutlet var collectionViewDropZone: UICollectionView! {
        didSet {
            collectionViewDropZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
//        print("canHandle drop func gets called")
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
//        print("dropSessionDidUpdate func gets called")
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
//        print("performDropWith gets called")
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
//                print("item.dragItem.localObject equals \(String(describing: item.dragItem.localObject))")
                if let image = item.dragItem.localObject as? UIImage {
//                    print("image is \(image)")
                    collectionView.performBatchUpdates({
                        loadedImages.remove(at: sourceIndexPath.item)
                        loadedImages.insert(image, at: destinationIndexPath.item)
                        ImageGalleryTableViewController?.artistURLDictionary[selectedArtist!]?.remove(at: sourceIndexPath.item)
                        ImageGalleryTableViewController?.artistURLDictionary[selectedArtist!]?.insert(currentArtistURLs![sourceIndexPath.item], at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
//                        print("loadedImages finishes as \(loadedImages)")
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceholderCell"))
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self, completionHandler: { (provider, error) in
                    DispatchQueue.main.async {
                        if let url = provider as? URL {
                            let cleanURL = url.imageURL
                                placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                    self.currentArtistURLs!.insert(cleanURL, at: insertionIndexPath.item)
                                    self.ImageGalleryTableViewController?.artistURLDictionary[self.selectedArtist!]?.insert(cleanURL, at: insertionIndexPath.item)
                                })
                            }
                             else {
                            placeholderContext.deletePlaceholder()
                        }
                    }
                })
            }
        }
    }
    
    var imageView = UIImageView()
    
    var selectedArtist: String?
    
    var loadedImages = [UIImage?]()
    
    var currentArtistURLs: [URL?]? {
        didSet {
            loadedImages = []
//            print("CurrentartistURLs is \(String(describing: currentArtistURLs))")
            for _ in currentArtistURLs!.indices {
                loadedImages.append(nil)
            }
            fetchCurrentArtistImages()
        }
    }
    
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
        for index in currentArtistURLs!.indices {
            loadedImages[index] = nil
            if let unwrappedURL = currentArtistURLs![index] {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    let urlContents = try? Data(contentsOf: unwrappedURL)
                    DispatchQueue.main.async {
//                        print("currentArtistURLs is \(String(describing: self?.currentArtistURLs?.indices))")
//                        print("loadedImages is \(String(describing: self?.loadedImages.indices))")
                        if let imageData = urlContents {
//                            print("imageData is \(imageData)")
//                            print("UIImage is \(String(describing: UIImage(data: imageData)))")
                            if let loadedImage = UIImage(data: imageData) {
//                                print("Index count of loadedImages before fail is \(String(describing: self?.loadedImages.indices))")
                                self?.loadedImages[index] = loadedImage
//                                print("Loaded images contains \(String(describing: self?.loadedImages[index]))")
                                self?.collectionView.reloadData()
                            }
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
        return currentArtistURLs?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! IGCollectionViewCell
        //        print("collectionView cellForItemAt func is called!")
        
        // Configure the cell
//        print("imageURL starts out as \(String(describing: imageURL))")
        cell.spinner.startAnimating()
        if loadedImages[indexPath.item] != nil {
//            print("loadedimages.count is \(loadedImages.count)")
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
