//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by john sanford on 8/14/19.
//  Copyright © 2019 Jack Sanford. All rights reserved.
//

import UIKit

private let reuseIdentifier = "collectionCell"

class ImageGalleryCollectionViewController: UICollectionViewController, UIGestureRecognizerDelegate, UIDropInteractionDelegate, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UICollectionViewDelegateFlowLayout {

    // Cache Properties
    
    private var cache = URLCache.shared
    private var session = URLSession(configuration: .default)
    
    // MARK: Update Model
        
    var gallery: ImageGallery! {
        didSet {
            title = gallery?.title
            collectionView?.reloadData()
        }
    }
    
    // MARK: Need to access our UIDocument
    
    var document: ImageGalleryDocument?
    
    // MARK: Save Document Button
    
    @IBAction func save(_ sender: UIBarButtonItem? = nil) {
        document?.gallery = gallery
        if document?.gallery != nil {
            document?.updateChangeCount(.done)
        }
    }
    
    // MARK: Close Document (Done) Button
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        save()
        dismiss(animated: true) {
            self.document?.close()
        }
    }
    
    // MARK: View Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        document?.open { success in
            if success {
//                print("document after opening is \(String(describing: self.document))")
//                print("document localized name is \(String(describing: self.document?.localizedName))")
//                print("document gallery is \(String(describing: self.document?.gallery))")
                if self.gallery == nil && self.document?.gallery == nil {
                    self.gallery = ImageGallery(images: [], title: self.document?.localizedName ?? "TITLE")
                } else {
                    self.gallery = self.document?.gallery
                    self.title = self.document?.localizedName
                }
            }
        }
    }
    
//    func makeGallery() -> ImageGallery {
//        return ImageGallery(
//            images: [],
//            title: "Untitled.json"
//        )
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        flowLayout?.minimumLineSpacing = 5
        flowLayout?.minimumInteritemSpacing = 5
        cache = URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
    }
    
    // MARK: - Prepares ImageView controller for segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination
        if let navcon = destination as? UINavigationController {
            destination = navcon.visibleViewController ?? navcon
        }
        if let imageVC = destination as? ImageViewController {
            if let senderCell = sender as? IGCollectionViewCell {
                if let indexPath = collectionView?.indexPath(for: senderCell),
                    let selectedImage = gallery?.images[indexPath.item] {
                    imageVC.finalImage = UIImage(data: selectedImage.imageData!)
                }
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
            let galleryImage = gallery.images[indexPath.item]
            let aspectRatio = galleryImage.aspectRatio
        var itemHeight = itemWidth / CGFloat(aspectRatio)
        if itemHeight <= (collectionView.frame.size.height / 2) {
            itemHeight = collectionView.frame.size.height / 2
            return CGSize(width: itemWidth, height: itemHeight)
        }
        
            return CGSize(width: itemWidth, height: itemHeight)
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
        var dragItems = [UIDragItem]()
        
        if let galleryImage = gallery?.images[indexPath.item] {
            if let imageURL = galleryImage.imagePath as NSURL? {
                let urlItem = UIDragItem(itemProvider: NSItemProvider(object: imageURL))
                urlItem.localObject = galleryImage
                dragItems.append(urlItem)
            }
        }
        return dragItems
    }
    
    // MARK: - Drop Items
    
    @IBOutlet var collectionViewDropZone: UICollectionView! {
        didSet {
            collectionViewDropZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        if collectionView.hasActiveDrag {
            // if drag is internal, image is not needed
            return session.canLoadObjects(ofClass: URL.self)
        } else {
            return session.canLoadObjects(ofClass: URL.self) && session.canLoadObjects(ofClass: UIImage.self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                // Drag was initiated from inside Collection View
                if let galleryImage = item.dragItem.localObject as? ImageGallery.Image {
                    collectionView.performBatchUpdates({
                        self.gallery.images.remove(at: sourceIndexPath.item)
                        self.gallery.images.insert(galleryImage, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                // Drag was initiated from outside app
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: reuseIdentifier))
                
                // Made up image for placeholder
                var draggedImage = ImageGallery.Image(imagePath: nil, aspectRatio: 1)
                
                // Loads the image
                _ = item.dragItem.itemProvider.loadObject(ofClass: UIImage.self){ (provider, error) in
                    DispatchQueue.main.async {
                        if let image = provider as? UIImage {
                            draggedImage.aspectRatio = image.aspectRatio
                        }
                    }
                    
                }
                
                // Loads the URL
                _ = item.dragItem.itemProvider.loadObject(ofClass: URL.self) { (provider, error) in
                    if let url = provider?.imageURL {
                        draggedImage.imagePath = url
                        let request = URLRequest(url: url)
                        if let cachedResponse = self.cache.cachedResponse(for: request), let _ = UIImage(data: cachedResponse.data) {
                            placeholderContext.commitInsertion { indexPath in
                                draggedImage.imageData = cachedResponse.data
                                self.insertImage(draggedImage, at: indexPath)
                            }
                        } else {
                            // Downloads the image from the fetched URL
                            URLSession(configuration: .default).dataTask(with: url) { (data, URLresponse, error) in DispatchQueue.main.async {
                                if let data = data, let _ = UIImage(data: data) {
                                    if let response = URLresponse {
                                        self.cache.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
                                    }
                                    placeholderContext.commitInsertion { indexPath in
                                        draggedImage.imageData = data
                                        self.insertImage(draggedImage, at: indexPath)
                                    }
                                } else {
                                    // There was an error. Remove the placeholder.
                                    placeholderContext.deletePlaceholder()
                                }
                                }
                                
                                }.resume()
                        }
                    }
                }
            }
        }
    }
    
    private func insertImage(_ image: ImageGallery.Image, at indexPath: IndexPath) {
        gallery?.images.insert(image, at: indexPath.item)
//        print("gallery?.images is \(String(describing: gallery?.images))")
//        print("Updated Gallery images count to \(String(describing: gallery?.images.count))")
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery?.images.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        guard let galleryImage = gallery?.images[indexPath.item] else {return cell}
        
        // Configure the cell
        
        if let imageCell = cell as? IGCollectionViewCell {
            imageCell.spinner.startAnimating()
            if let data = galleryImage.imageData, let image = UIImage(data: data) {
                imageCell.imageView.image = image
                imageCell.spinner.stopAnimating()
            }
        }
        
        return cell
    }

}
