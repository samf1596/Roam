//
//  ProfilePostViewController.swift
//  Roam
//
//  Created by Samuel Fox on 1/3/19.
//  Copyright © 2019 sof5207. All rights reserved.
//

import UIKit
import Firebase

class ProfilePostViewController: UIViewController, UINavigationBarDelegate, UITextViewDelegate, UINavigationControllerDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count > 1 {
            self.databaseRef.child(FirebaseFields.Posts.rawValue).child(post!.postID).child("Comments").child("\(Int(Date.timeIntervalSinceReferenceDate * 1000))").setValue(textView.text)
            textView.text = "Leave a comment..."
        }
        else {
            textView.text = "Leave a comment..."
        }
        textView.resignFirstResponder()
    }
    
    var previousHeight : CGFloat = 25.0
    var kKeyboardSize : CGFloat = 0.0
    var keyboardVisible = false
    
    @objc func keyboardWillShow(notification:Notification) {
        if !keyboardVisible && ( self.view.traitCollection.horizontalSizeClass != UIUserInterfaceSizeClass.regular ) {
            let userInfo = notification.userInfo!
            let keyboardSize = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect
            if self.view.frame.origin.y == previousHeight {
                self.view.frame.origin.y -= ((keyboardSize!.height) - submitCommentTextView.frame.height)
            }
        }
        
        keyboardVisible = true
    }
    
    @objc
    func keyboardWillHide(notification:Notification) {
        if keyboardVisible && ( self.view.traitCollection.horizontalSizeClass != UIUserInterfaceSizeClass.regular ) {
            if self.view.frame.origin.y != previousHeight {
                self.view.frame.origin.y = previousHeight
            }
        }
        keyboardVisible = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previousHeight = self.view.frame.origin.y
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name:
            UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func onNotification(notification:Notification) {
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.view.backgroundColor = UIColor.darkGray
                self.submitCommentTextView.backgroundColor = UIColor.white
                self.postDetailsTextView.backgroundColor = UIColor.gray
                self.submitCommentTextView.keyboardAppearance = .dark
                
                self.bookmarkPostButton.setImage(UIImage(named: "bookmark-white"), for: .normal)
                self.postViewCommentsButton.setImage(UIImage(named: "comments-white"), for: .normal)
                self.bookmarkPostButton.setImage(UIImage(named: "bookmark-white"), for: .normal)
                self.moreActionsButton.setImage(UIImage(named: "ellipsis-white"), for: .normal)
                self.postDetailsButton.setImage(UIImage(named: "details-white"), for: .normal)
            }
            else {
                self.view.backgroundColor = UIColor.white
                self.submitCommentTextView.backgroundColor = UIColor.white
                self.postDetailsTextView.backgroundColor = UIColor.white
                self.submitCommentTextView.keyboardAppearance = .default
                
                self.bookmarkPostButton.setImage(UIImage(named: "bookmark"), for: .normal)
                self.postViewCommentsButton.setImage(UIImage(named: "comments"), for: .normal)
                self.moreActionsButton.setImage(UIImage(named: "ellipsis"), for: .normal)
                self.postDetailsButton.setImage(UIImage(named: "details"), for: .normal)
                self.bookmarkPostButton.setImage(UIImage(named: "bookmark"), for: .normal)
            }
            if postsModel.postIdBookmarked(post!) {
                bookmarkPostButton.backgroundColor = UIColor.orange
                bookmarkPostButton.setImage(UIImage(named: "bookmark-white"), for: .normal)
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
    @IBOutlet weak var firstImageView: UIImageView!
    
    var post : Post?
    var postIndex = 0
    var usersPosts = true
    var viewUserProfile = false
    
    let postsModel = PostsModel.sharedInstance
    
    fileprivate var storageRef : StorageReference!
    fileprivate var downloadImageTask : StorageDownloadTask!
    fileprivate var databaseRef : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitCommentTextView.delegate = self
        submitCommentTextView.returnKeyType = .done
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: SettingsViewController.settingsChanged, object: nil)
        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Light.rawValue])
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Dark.rawValue])
        }
        if viewUserProfile {
                self.title = (post?.firstname)! + "'s" + " Post"
        } else {
            if usersPosts {
                followUserButton.setTitle("Delete", for: .normal)
                followUserButton.backgroundColor = UIColor.red
                self.title = "Your Post"
                moreActionsButton.isHidden = true
            }
            else {
                self.title = (post?.firstname)! + "'s" + " Post"
            }
        }
        self.postLocationButton.setTitle(Array((post?.locations.keys)!)[0], for: .normal)
        if Array((post?.locations.keys)!)[0] == "NONE" {
            postLocationButton.isHidden = true
        }
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
        postFirstImageButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        postDetailsTextView.text = post?.description
        if viewUserProfile {
                let imagePath = postsModel.imagePathForUserToViewPost(postIndex, 0)
                let storageImagePath = storageRef.storage.reference(forURL: imagePath)
                firstImageView.sd_setImage(with: storageImagePath, placeholderImage: UIImage(named: "addPhoto"))
        } else {
            if usersPosts {
                let imagePath = postsModel.imagePathForUsersPost(postIndex, 0)
                postsModel.downloadUsersPostImage(postIndex, imagePath, post!.postID)
                
                let storageImagePath = storageRef.storage.reference(forURL: imagePath)
                firstImageView.sd_setImage(with: storageImagePath, placeholderImage: UIImage(named: "addPhoto"))
            }
            else {
                let imagePath = postsModel.imagePathForBookmarkedPost(postIndex, 0)
                postsModel.downloadBookmarkedImage(postIndex, imagePath, post!.postID)

                let storageImagePath = storageRef.storage.reference(forURL: imagePath)
                firstImageView.sd_setImage(with: storageImagePath, placeholderImage: UIImage(named: "addPhoto"))
            }
        }
    }
    
    func configure(_ post: Post, _ cellSelected: Int, _ usersPosts: Bool, _ viewUserProfile: Bool = false) {
        self.post = post
        self.postIndex = cellSelected
        self.usersPosts = usersPosts
        self.viewUserProfile = viewUserProfile
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
        if bookmarkPostButton.backgroundColor == UIColor.orange {
            bookmarkPostButton.backgroundColor = UIColor.clear
            if UserDefaults.standard.bool(forKey: "DarkMode") == true {
                self.bookmarkPostButton.setImage(UIImage(named: "bookmark-white"), for: .normal)
            }
            else {
                self.bookmarkPostButton.setImage(UIImage(named: "bookmark"), for: .normal)
            }
            let currentUser = databaseRef.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid)
            currentUser.child("Bookmarks").child((post?.postID)!).removeValue()
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
        }
        else {
            bookmarkPostButton.backgroundColor = UIColor.orange
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
    
    @IBAction func moreOptions(_ sender: Any) {
        let alert = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Report Post", style: .destructive) { (action) in
            
            self.databaseRef.child(FirebaseFields.Reported.rawValue).child(self.post!.postID).child("Times").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists(){
                    print(snapshot)
                    let count = snapshot.value as! Int
                    
                    if count + 1 > 2 {
                        self.databaseRef.child(FirebaseFields.UnderReview.rawValue).child(self.post!.postID).setValue(true)
                    }
                    else {
                        let post = self.databaseRef.child(FirebaseFields.Reported.rawValue).child(self.post!.postID)
                        post.child("Times").setValue(count+1)
                    }
                }
                else {
                    let post = self.databaseRef.child(FirebaseFields.Reported.rawValue).child(self.post!.postID)
                    post.child("Times").setValue(1)
                }
                let currentUser = self.databaseRef.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid)
                currentUser.child("Hidden").child(self.post!.postID).setValue(true)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
            })
        })
        alert.addAction(UIAlertAction(title: "Hide Post", style: .destructive) { (action) in
            let currentUser = self.databaseRef.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid)
            currentUser.child("Hidden").child(self.post!.postID).setValue(true)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
        })
        alert.addAction(UIAlertAction(title: "Block User", style: .destructive) { (action) in
            let currentUser = self.databaseRef.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid)
            currentUser.child("Blocked").child(self.post!.username).setValue(true)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
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
                if viewUserProfile{
                    whatPosts = "ViewUserProfile"
                } else {
                    if usersPosts {
                        whatPosts = "User"
                    }
                    else {
                        whatPosts = "Bookmarked"
                    }
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
