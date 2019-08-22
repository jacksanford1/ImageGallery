//
//  artistCollection.swift
//  ImageGallery
//
//  Created by john sanford on 8/20/19.
//  Copyright © 2019 Jack Sanford. All rights reserved.
//

import Foundation

/// Model representing a gallery with it's images.
struct ImageGallery: Hashable, Codable {
    
    /// Model representing a gallery's image.
    struct Image: Hashable, Codable {
        
        // MARK: - Hashable
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(imagePath)
        }
        
        static func ==(lhs: ImageGallery.Image, rhs: ImageGallery.Image) -> Bool {
            return lhs.imagePath == rhs.imagePath
        }
        
        // MARK: - Properties
        
        /// The image's URL.
        var imagePath: URL?
        
        /// The image's aspect ratio.
        var aspectRatio: Double
        
        /// The fetched image's data.
        var imageData: Data?
        
        /// MARK: - Initializer
        
        init(imagePath: URL?, aspectRatio: Double) {
            self.imagePath = imagePath
            self.aspectRatio = aspectRatio
        }
    }
    
    // MARK: - Properties
    
    /// The gallery's identifier.
    var identifier: String = UUID().uuidString
    
    /// The gallery's images.
    var images: [Image]
    
    /// The gallery's title.
    var title: String
    
    // Initialize the ImageGallery
    
    init(images: [Image], title: String) {
        self.images = images
        self.title = title
    }
    
    // Decoding itself from json
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(ImageGallery.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    // Encoding itself in json
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func ==(lhs: ImageGallery, rhs: ImageGallery) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
}
