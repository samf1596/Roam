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

    @objc func onNotification(notification:Notification) {
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.view.backgroundColor = UIColor.darkGray
                //self.backgroundColorView.backgroundColor = UIColor.darkGray
                self.submitCommentTextView.backgroundColor = UIColor.white
                self.postDetailsTextView.backgroundColor = UIColor.gray
                self.submitCommentTextView.keyboardAppearance = .dark
                
                self.bookmarkPostButton.imageView?.image = UIImage(named: "bookmark-white")
                self.postViewCommentsButton.imageView?.image = UIImage(named: "comments-white")
                self.moreActionsButton.imageView?.image = UIImage(named: "ellipsis-white")
                self.postDetailsButton.imageView?.image = UIImage(named: "details-white")
            }
            else {
                self.view.backgroundColor = UIColor.white
                //self.backgroundColorView.backgroundColor = UIColor.darkGray
                self.submitCommentTextView.backgroundColor = UIColor.white
                self.postDetailsTextView.backgroundColor = UIColor.white
                self.submitCommentTextView.keyboardAppearance = .default
                
                self.bookmarkPostButton.imageView?.image = UIImage(named: "bookmark")
                self.postViewCommentsButton.imageView?.image = UIImage(named: "comments")
                self.moreActionsButton.imageView?.image = UIImage(named: "ellipsis")
                self.postDetailsButton.imageView?.image = UIImage(named: "details")
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: SettingsViewController.settingsChanged, object: nil)
    }
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: SettingsViewController.settingsChanged, object: nil)
        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Light.rawValue])
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Dark.rawValue])
        }
        
        if usersPosts {
            followUserButton.setTitle("Delete", for: .normal)
            self.title = "Your Post"
            moreActionsButton.isHidden = true
        }
        else {
            self.title = (post?.firstname)! + "'s" + " Post"
        }
        self.postLocationButton.setTitle(Array((post?.locations.keys)!)[0], for: .normal)
        storageRef = Storage.storage().reference()
        databaseRef = Database.database().reference()
        if followUserButton.title(for: .normal) != "Delete" {
            if let currentPost = post {
                if postsModel.followingUser(currentPost) {
                    followUserButton.setTitle("Unfollow", for: .normal)
                }
                else {
                    followUserButton.setTitle("Follow", for: .normal)
                }
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
            bookmarkPostButton.backgroundColor = UIColor.orange
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
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
        }
        if sender.titleLabel?.text == "Unfollow" {
            let currentUser = databaseRef.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid)
            currentUser.child("following").child((post?.username)!).removeValue()
            sender.setTitle("Follow", for: .normal)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
        }
        if sender.titleLabel?.text == "Delete" {
            let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this post? This cannot be undone.", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.databaseRef.child(FirebaseFields.Posts.rawValue).child((self.post?.postID)!).removeValue()
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
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
            case "ShowDetails":
                let detailsController = segue.destination as! PostExperienceDetailsTableViewController
                detailsController.configure((post?.travels)!, (post?.experiences)!)
            case "ShowComments":
                let commentsController = segue.destination as! CommentsTableViewController
                commentsController.configure((post?.postID)!)
            default:
                assert(false, "Unhandled Segue")
        }
    }
    

}
