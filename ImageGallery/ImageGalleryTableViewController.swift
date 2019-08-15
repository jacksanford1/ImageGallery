//
//  ImageGalleryTableViewController.swift
//  ImageGallery
//
//  Created by john sanford on 8/13/19.
//  Copyright © 2019 Jack Sanford. All rights reserved.
//

import UIKit

class ImageGalleryTableViewController: UITableViewController {
    
    var imageGalleryDocuments = ["Yaeji", "Big Wild", "Santigold"]

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageGalleryDocuments.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = imageGalleryDocuments[indexPath.row]

        return cell
    }
    
    @IBAction func newImageGalleryDocument(_ sender: UIBarButtonItem) {
        imageGalleryDocuments += ["Untitled".madeUnique(withRespectTo: imageGalleryDocuments)]
        tableView.reloadData()
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            imageGalleryDocuments.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        var identifier: String
//        switch indexPath.row {
//        case 0 : identifier = "Cassini"
//        case 1 : identifier = "Pattern"
//        case 2 : identifier = "Santigold"
//        default : identifier = "False"; print("Didn't work")
//        }
//
//        let VC = ImageViewController
//
//    }
    
    let segueIdentifier = "ShowImageSegue"

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier,
            let imageIndex = tableView.indexPathForSelectedRow?.row {
            var identifier: String
            switch imageIndex {
            case 0 : identifier = imageGalleryDocuments[0]
            case 1 : identifier = imageGalleryDocuments[1]
            case 2 : identifier = imageGalleryDocuments[2]
            default : identifier = "False"; print("Didn't work")
            }
            if let url = DemoURLs.NASA[identifier] {
                var destination = segue.destination
                if let navcon = destination as? UINavigationController {
                    destination = navcon.visibleViewController ?? navcon
                }
                if let imageVC = destination as? ImageViewController {
                    imageVC.imageURL = url
                    imageVC.title = identifier
                }
            }
        }
    }
    

}
