//
//  ProfileViewController.swift
//  Roam
//
//  Created by Samuel Fox on 11/5/18.
//  Copyright © 2018 sof5207. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MainViewDelegate {
    
    fileprivate var ref : DatabaseReference!
    fileprivate var storageRef : StorageReference!
    
    @objc func onNotification(notification:Notification) {
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.view.tintColor = UIColor.white
                self.view.backgroundColor = UIColor.darkGray
                self.profileCollectionView.backgroundView?.backgroundColor = UIColor.darkGray
                self.profileCollectionView.backgroundColor = UIColor.darkGray
            }
            else {
                self.view.backgroundColor = UIColor.white
                self.view.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.profileCollectionView.backgroundView?.backgroundColor = UIColor.white
                self.profileCollectionView.backgroundColor = UIColor.white
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: SettingsViewController.settingsChanged, object: nil)
    }
    
    @IBOutlet weak var profileCollectionView: UICollectionView!
    
    var collectionToShow = "UsersPosts"
    var pageTitle = String()
    
    let postModel = PostsModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: SettingsViewController.settingsChanged, object: nil)
        
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Dark.rawValue])
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Light.rawValue])
        }
        
        profileCollectionView.dataSource = self
        profileCollectionView.delegate = self
        
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
    }
    
    func toggleCollectionViewType(show collection: String) {
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
        self.collectionToShow = collection
        profileCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        postModel.findUsersPosts()
        postModel.findBookmarkedPosts()
        self.profileCollectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionToShow == "UsersPosts" {
            return postModel.cachedUsersPostsCount
        }
        else {
            return postModel.cachedBookmarkedPostsCount
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath) as! ProfileCollectionViewCell
        
        if collectionToShow == "BookmarkedPosts"{
            let imagePath = postModel.imagePathForBookmarkedPost(indexPath.row, 0)
            let post = postModel.postForBookmarkedSection(indexPath.row)
            
            postModel.downloadBookmarkedImage(indexPath.row, imagePath, post.postID)
            cell.postImageView.image = postModel.getCachedImage(post.postID+"\(0)")
        }
        else {
            let imagePath = postModel.imagePathForUsersPost(indexPath.row,0)
            let post = postModel.postForUsersSection(indexPath.row)
            
            postModel.downloadUsersPostImage(indexPath.row, imagePath, post.postID)
            cell.postImageView.image = postModel.getCachedImage(post.postID+"\(0)")
        }
        return cell
    }
    
}

