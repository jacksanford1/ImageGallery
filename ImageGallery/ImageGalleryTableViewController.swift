//
//  ImageGalleryTableViewController.swift
//  ImageGallery
//
//  Created by john sanford on 8/13/19.
//  Copyright © 2019 Jack Sanford. All rights reserved.
//

import UIKit

class ImageGalleryTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    let section = ["Image Gallery", "Recently Deleted"]
    
    var imageGalleryDocuments = [["Yaeji", "Big Wild", "Santigold"], ["Test"]]
    
    var recentlyDeletedDocuments: [String] = []
    
    var textCellLocation: IndexPath?
    
    var artistURLDictionary : [String:[URL?]] = [
        "Yaeji":[
            URL(string: "https://media.wired.com/photos/5beca56498b3a67ce2873d69/master/pass/Yaeji-Micaiah-Carter.jpg"),
            URL(string: "https://i1.wp.com/thebaybridged.com/wp-content/uploads/2018/06/yaeji-rachel_wright.jpg?fit=1920%2C1531"),
            URL(string: "https://cdn.pitchfork.com/longform/642/001_YAEJI_JEmmerman.jpg")
        ],
        "Big Wild":[
            URL(string: "https://pbs.twimg.com/media/CjU4tlFVAAAXZfz.jpg"),
            URL(string: "https://images.sk-static.com/images/media/profile_images/artists/8351553/huge_avatar"),
            URL(string: "https://i2.wp.com/thissongissick.com/wp-content/uploads/2019/01/Screen-Shot-2019-01-10-at-10.20.09-AM.png?w=640&quality=88&strip&ssl=1")
        ],
        "Santigold":[
            URL(string: "https://musicmixdaily.com/wp-content/uploads/2016/04/santigold-2.jpg"),
            URL(string: "https://www.billboard.com/files/styles/article_main_image/public/media/Santigold-press-photo-by-Christelle-de-Castro-2017-billboard-1548.jpg"),
            URL(string: "https://static.spin.com/files/120517-santi-1-640x426.png")
        ]]
    
    func addURL(for URL: URL, artist: String) {
        artistURLDictionary[artist]?.append(URL)
    }
    
//    var demoURLstruct = DemoURLs()

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section[section]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.section.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageGalleryDocuments[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if textCellLocation != nil && textCellLocation == indexPath {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: textCellLocation!)
            if let inputCell = cell as? TextFieldTableViewCell {
                inputCell.resignationHandler = { [weak self] in
                    if let text = inputCell.textField.text {
                        if let oldTitle = self?.imageGalleryDocuments[indexPath.section][indexPath.row] {
                            self?.artistURLDictionary.switchKey(fromKey: oldTitle, toKey: text)
                        }
                        self?.imageGalleryDocuments[indexPath.section][indexPath.row] = text
                    }
                    self?.textCellLocation = nil
                    self?.tableView.reloadData()
                }
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath)
            
             cell.textLabel?.text = imageGalleryDocuments[indexPath.section][indexPath.row]
            
            return cell
        }
    }
    
    // MARK: - Create new Artist
    
    @IBAction func newImageGalleryDocument(_ sender: UIBarButtonItem) {
        let newDoc = "Untitled".madeUnique(withRespectTo: imageGalleryDocuments[0])
        imageGalleryDocuments[0] += [newDoc]
        artistURLDictionary[newDoc] = []
        tableView.reloadData()
    }
    
    // MARK: - Allow Table View to be hidden
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        DispatchQueue.main.async {
            if self.splitViewController?.preferredDisplayMode != .primaryOverlay {
                self.splitViewController?.preferredDisplayMode = .primaryOverlay
            }
        }
    }
    
    // MARK: - Double Tap to Edit
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        tableView.addGestureRecognizer(doubleTap)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let inputCell = cell as? TextFieldTableViewCell {
            inputCell.textField.becomeFirstResponder()
        }
    }
    
    @objc func didDoubleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizer.State.ended {
            let tapLocation = recognizer.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
//                if let tappedCell = self.tableView.cellForRow(at: tapIndexPath) {
                    textCellLocation = tapIndexPath
                    tableView.reloadData()
//                }
            }
        }
    }
   

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // MARK: - Deleting Artists from table view
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 0 {
                let docToBeDeleted = imageGalleryDocuments[0][indexPath.row]
                imageGalleryDocuments[0].remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                imageGalleryDocuments[1].append(docToBeDeleted)
                tableView.reloadData()
            } else if indexPath.section == 1 {
                artistURLDictionary[imageGalleryDocuments[1][indexPath.row]] = nil
                imageGalleryDocuments[1].remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    // MARK: - Undeleting Artists from table view
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
        let title = NSLocalizedString("Undelete", comment: "Undelete")
        
        
        let action = UIContextualAction(style: .normal, title: title, handler: { (action, view, completionHandler) in
            let undeletedRow = self.imageGalleryDocuments[indexPath.section][indexPath.row]
            self.imageGalleryDocuments[1].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.imageGalleryDocuments[0].append(undeletedRow)
            tableView.reloadData()
            completionHandler(true)
            })
        
        action.backgroundColor = .green
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
        
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
    
    let segueIdentifier = "ShowCollectionSegue"

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("Segue identifier is \(segueIdentifier)")
        let sectionIndex = tableView.indexPathForSelectedRow?.section
        if segue.identifier == segueIdentifier && sectionIndex == 0,
            let artistIndex = tableView.indexPathForSelectedRow?.row {
            print("artistIndex is \(artistIndex)")
            let identifier = imageGalleryDocuments[0][artistIndex]
            print("identifier is \(identifier)")
            
                var destination = segue.destination
//                print("destination is \(destination)")
                if let navcon = destination as? UINavigationController {
                    destination = navcon.visibleViewController ?? navcon
//                    print("New destination is \(destination)")
                }
                if let imageVC = destination as? ImageGalleryCollectionViewController {
//                    print("imageVC is \(imageVC)")
//                    imageVC.currentArtist = urls as? [URL]
//                    print("Newly set imageURL is \(imageVC.imageURL!)")
                    imageVC.selectedArtist = identifier
//                    print("identifier sent is \(identifier)")
                    imageVC.currentArtistURLs = artistURLDictionary[identifier]
//                    print("URLs sent is \(String(describing: artistURLDictionary[identifier]))")
                    imageVC.ImageGalleryTableViewController = self
                }
            
        }
    }
    

}

extension Dictionary {
    mutating func switchKey(fromKey: Key, toKey: Key) {
        if let entry = removeValue(forKey: fromKey) {
            self[toKey] = entry
        }
    }
}
