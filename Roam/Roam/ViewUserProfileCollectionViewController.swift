//
//  ViewUserProfileCollectionViewController.swift
//  Roam
//
//  Created by Samuel Fox on 1/31/19.
//  Copyright © 2019 sof5207. All rights reserved.
//

import UIKit
import Firebase

class ViewUserProfileCollectionViewController: UICollectionViewController {

    fileprivate var ref : DatabaseReference!
    fileprivate var storageRef : StorageReference!
    
    let postModel = PostsModel.sharedInstance
    
    func configure(_ index: Int, _ sender: String) {
        if sender == "Home" {
            let UID = postModel.postForFollowingSection(index).username
            postModel.findPostsForUserWithID(UID, "Home")
        } else {
            let UID = postModel.postForGlobalSection(index).username
            postModel.findPostsForUserWithID(UID, "Global")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")

        collectionView.dataSource = self
        collectionView.delegate = self
        
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return postModel.cachedUserPostToViewCount
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ProfileCollectionViewCell
        
        let imagePath = postModel.imagePathForUserToViewPost(indexPath.row, 0)
        let post = postModel.postForUserPostToViewSection(indexPath.row)
        cell.post = post
        if self.title == nil {
            self.title = post.firstname
        }
        postModel.downloadUsersPostToViewImage(indexPath.row, imagePath, post.postID)
        cell.postImageView.image = postModel.getCachedImage(post.postID+"\(0)")
    
        return cell
    }

    // MARK: UICollectionViewDelegate

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
