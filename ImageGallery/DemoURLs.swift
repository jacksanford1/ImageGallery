//
//  DemoURLs.swift
//  ImageGallery
//
//  Created by john sanford on 8/12/19.
//  Copyright © 2019 Jack Sanford. All rights reserved.
//

import Foundation

struct DemoURLs {
    
    static let berkeley = Bundle.main.url(forResource: "campanile", withExtension: "jpg")
    
    static var NASA: Dictionary<String, URL> = {
        let NASAURLStrings = [
            "Yaeji" : "https://media.wired.com/photos/5beca56498b3a67ce2873d69/master/pass/Yaeji-Micaiah-Carter.jpg",
            "Big Wild" :
                "https://pbs.twimg.com/media/CjU4tlFVAAAXZfz.jpg",
            "Santigold" : "https://musicmixdaily.com/wp-content/uploads/2016/04/santigold-2.jpg"
        ]
        var urls = Dictionary<String, URL>()
        for (key, value) in NASAURLStrings {
            urls[key] = URL(string: value)
        }
        return urls
    }()
    
}
