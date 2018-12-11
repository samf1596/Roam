//
//  AllImagesTableViewController.swift
//  Roam
//
//  Created by Samuel Fox on 12/8/18.
//  Copyright © 2018 sof5207. All rights reserved.
//

import UIKit

class AllImagesTableViewController: UITableViewController {

    var images = [UIImage]()
    var imageURLS = [String]()
    var postIndex = Int()
    var whichPosts = String()
    
    let postsModel = PostsModel.sharedInstance
    @objc func onNotification(notification:Notification) {
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.tableView.tintColor = UIColor.white
                self.tableView.backgroundColor = UIColor.darkGray
            }
            else {
                self.tableView.backgroundColor = UIColor(red: 5.0/255.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.tableView.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: SettingsViewController.settingsChanged, object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: SettingsViewController.settingsChanged, object: nil)
        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Light.rawValue])
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Dark.rawValue])
        }
    }

    // MARK: - Table view data source
    func configure(_ postIndex: Int, _ whichPosts: String) {
        self.postIndex = postIndex
        self.whichPosts = whichPosts
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if whichPosts == "Global" {
            return postsModel.postForSection(postIndex).imagePath.count
        }
        if whichPosts == "Home" {
            return postsModel.postForFollowingSection(postIndex).imagePath.count
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Image", for: indexPath) as! ImageViewPostTableViewCell
        
        if whichPosts == "Global" {
            let post = postsModel.postForSection(postIndex)
            
            let imagePath = postsModel.imagePathForPost(postIndex, indexPath.row)
            postsModel.downloadImage(indexPath, imagePath, post.postID)
            
            cell.postImageView.image = postsModel.getCachedImage(post.postID+"\(indexPath.row)")
        }
        if whichPosts == "Home" {
            let post = postsModel.postForFollowingSection(postIndex)
            let imagePath = postsModel.imagePathForFollowingPost(postIndex, indexPath.row)
            postsModel.downloadFollowingImage(indexPath, imagePath, post.postID)
            cell.postImageView.image = postsModel.getCachedImage(post.postID+"\(indexPath.row)")
        }

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
