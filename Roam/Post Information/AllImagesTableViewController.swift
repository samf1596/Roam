//
//  AllImagesTableViewController.swift
//  Roam
//
//  Created by Samuel Fox on 12/8/18.
//  Copyright © 2018 sof5207. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase

class AllImagesTableViewController: UITableViewController {

    
    fileprivate var ref : DatabaseReference!
    fileprivate var storageRef : StorageReference!
    
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
        
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if whichPosts == "Global" {
            return postsModel.postForGlobalSection(postIndex).imagePath.count
        }
        if whichPosts == "Home" {
            return postsModel.postForFollowingSection(postIndex).imagePath.count
        }
        if whichPosts == "User"{
            return postsModel.postForUsersSection(postIndex).imagePath.count
        }
        if whichPosts == "Bookmarked"{
            return postsModel.postForBookmarkedSection(postIndex).imagePath.count
        }
        if whichPosts == "ViewUserProfile" {
            return postsModel.postForUserPostToViewSection(postIndex).imagePath.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Image", for: indexPath) as! ImageViewPostTableViewCell
        
        if whichPosts == "Global" {
            let imagePath = postsModel.imagePathForGlobalPost(postIndex, indexPath.row)
            
            let storageImagePath = storageRef.storage.reference(forURL: imagePath)
            cell.postImageView.sd_setImage(with: storageImagePath, placeholderImage: UIImage(named: "addPhoto"))
        }
        if whichPosts == "Home" {
            let imagePath = postsModel.imagePathForFollowingPost(postIndex, indexPath.row)
            
            let storageImagePath = storageRef.storage.reference(forURL: imagePath)
            cell.postImageView.sd_setImage(with: storageImagePath, placeholderImage: UIImage(named: "addPhoto"))
        }
        if whichPosts == "User" {
            let imagePath = postsModel.imagePathForUsersPost(postIndex, indexPath.row)
            
            let storageImagePath = storageRef.storage.reference(forURL: imagePath)
            cell.postImageView.sd_setImage(with: storageImagePath, placeholderImage: UIImage(named: "addPhoto"))
        }
        if whichPosts == "Bookmarked" {
            let imagePath = postsModel.imagePathForBookmarkedPost(postIndex, indexPath.row)
            
            let storageImagePath = storageRef.storage.reference(forURL: imagePath)
            cell.postImageView.sd_setImage(with: storageImagePath, placeholderImage: UIImage(named: "addPhoto"))
        }
        if whichPosts == "ViewUserProfile" {
            let imagePath = postsModel.imagePathForUserToViewPost(postIndex, indexPath.row)
            
            let storageImagePath = storageRef.storage.reference(forURL: imagePath)
            cell.postImageView.sd_setImage(with: storageImagePath, placeholderImage: UIImage(named: "addPhoto"))
        }

        return cell
    }
    
}
