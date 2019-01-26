//
//  ProfilePostViewController.swift
//  Roam
//
//  Created by Samuel Fox on 1/3/19.
//  Copyright © 2019 sof5207. All rights reserved.
//

import UIKit
import Firebase

class ProfilePostViewController: UIViewController, UINavigationBarDelegate {

    @IBOutlet weak var followUserButton: UIButton!
    @IBOutlet weak var postLocationButton: UIButton!
    @IBOutlet weak var postFirstImageButton: UIButton!
    @IBOutlet weak var bookmarkPostButton: UIButton!
    @IBOutlet weak var postDetailsButton: UIButton!
    @IBOutlet weak var postViewCommentsButton: UIButton!
    @IBOutlet weak var moreActionsButton: UIButton!
    @IBOutlet weak var postDetailsTextView: UITextView!
    @IBOutlet weak var submitCommentTextView: UITextView!
    
    var post : Post?
    var postIndex = 0
    var usersPosts = true
    
    let postsModel = PostsModel.sharedInstance
    
    fileprivate var storageRef : StorageReference!
    fileprivate var downloadImageTask : StorageDownloadTask!
    fileprivate var databaseRef : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if usersPosts {
            followUserButton.isHidden = true
            self.title = "You"
        }
        else {
            self.title = (post?.firstname)! + "'s" + " Post"
        }
        self.postLocationButton.setTitle(Array((post?.locations.keys)!)[0], for: .normal)
        storageRef = Storage.storage().reference()
        databaseRef = Database.database().reference()
        
        if let currentPost = post {
            if postsModel.followingUser(currentPost) {
                followUserButton.setTitle("Unfollow", for: .normal)
            }
            else {
                followUserButton.setTitle("Follow", for: .normal)
            }
        }
        
        postLocationButton.layer.cornerRadius = 4.0
        followUserButton.layer.cornerRadius = 4.0
        bookmarkPostButton.layer.cornerRadius = 4.0
        
        postDetailsTextView.text = post?.description
        if usersPosts {
            let imagePath = postsModel.imagePathForUsersPost(postIndex, 0)
            postsModel.downloadUsersPostImage(postIndex, imagePath, post!.postID)
            
            let image = postsModel.getCachedImage(self.post!.postID+"\(0)")
            postFirstImageButton.setBackgroundImage(image, for: .normal)
            postFirstImageButton.setBackgroundImage(image, for: .selected)
        }
        else {
            let imagePath = postsModel.imagePathForBookmarkedPost(postIndex, 0)
            postsModel.downloadBookmarkedImage(postIndex, imagePath, post!.postID)

            let image = postsModel.getCachedImage(self.post!.postID+"\(0)")
            postFirstImageButton.setBackgroundImage(image, for: .normal)
            postFirstImageButton.setBackgroundImage(image, for: .selected)
        }
        
        if postsModel.postIdBookmarked(post!) {
            bookmarkPostButton.backgroundColor = UIColor.orange//.init(red: 105/255, green: 196/255, blue: 250/255, alpha: 1.0)
            bookmarkPostButton.imageView?.image = bookmarkPostButton.imageView!.image!.withRenderingMode(.alwaysTemplate)
            bookmarkPostButton.imageView!.tintColor = UIColor.white
        }
        else {
            bookmarkPostButton.backgroundColor = UIColor.clear
            bookmarkPostButton.imageView?.image = bookmarkPostButton.imageView!.image!.withRenderingMode(.alwaysTemplate)
            bookmarkPostButton.imageView!.tintColor = UIColor.black
        }
    }
    
    func configure(_ post: Post, _ cellSelected: Int, _ usersPosts: Bool) {
        self.post = post
        self.postIndex = cellSelected
        self.usersPosts = usersPosts
    }

    @IBAction func followButtonPressed(_ sender: UIButton) {
        if sender.titleLabel?.text == "Follow" {
            let currentUser = databaseRef.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid)
            currentUser.child("following").child((post?.username)!).setValue(true)
            sender.setTitle("Unfollow", for: .normal)
        }
        if sender.titleLabel?.text == "Unfollow" {
            let currentUser = databaseRef.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid)
            currentUser.child("following").child((post?.username)!).removeValue()
            sender.setTitle("Follow", for: .normal)
        }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
    }
    
    @IBAction func bookmarkButtonPressed(_ sender: UIButton) {
        if bookmarkPostButton.backgroundColor == UIColor.orange {//.init(red: 105/255, green: 196/255, blue: 250/255, alpha: 1.0) {
            bookmarkPostButton.backgroundColor = UIColor.clear
            self.bookmarkPostButton.imageView?.image = UIImage(named: "bookmark")
            let currentUser = databaseRef.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid)
            currentUser.child("Bookmarks").child((post?.postID)!).removeValue()
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
        }
        else {
            bookmarkPostButton.backgroundColor = UIColor.orange//.init(red: 105/255, green: 196/255, blue: 250/255, alpha: 1.0)
            UIView.animate(withDuration: 0.1, delay: 0.0,
                           options: [UIView.AnimationOptions.curveEaseInOut], animations: {
                            self.bookmarkPostButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }) { (true) in
                self.bookmarkPostButton.transform = CGAffineTransform.identity
                self.bookmarkPostButton.imageView?.image = UIImage(named: "bookmark-white")
            }
            
            let currentUser = databaseRef.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid)
            currentUser.child("Bookmarks").child((post?.postID)!).setValue(true)
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
            case "ShowImages":
                let viewController = segue.destination as! AllImagesTableViewController
                let index = postIndex
                var whatPosts = ""
                if usersPosts {
                    whatPosts = "User"
                }
                else {
                    whatPosts = "Bookmarked"
                }
                viewController.configure(index, whatPosts)
                self.navigationController?.navigationBar.isHidden = false
            case "ShowMap":
                let mapViewController = segue.destination as! MapViewController
                mapViewController.configure(post!.locations)
            default:
                assert(false, "Unhandled Segue")
        }
    }
    

}
