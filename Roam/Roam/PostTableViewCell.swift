//
//  PostTableViewCell.swift
//  
//
//  Created by Samuel Fox on 11/4/18.
//

import UIKit
import Firebase

class PostTableViewCell: UITableViewCell, UITextViewDelegate {

    fileprivate var storageRef : StorageReference!
    fileprivate var downloadImageTask : StorageDownloadTask!
    fileprivate var databaseRef : DatabaseReference!
    
    
    @IBOutlet weak var backgroundColorView: UIView!
    @IBOutlet weak var globalPostersName: UILabel!
    @IBOutlet weak var globalPosterUsername: UILabel!
    @IBOutlet weak var globalPostImageView: UIImageView!
    @IBOutlet weak var globalPostExperienceDetails: UIButton!
    @IBOutlet weak var globalPostFavButton: UIButton!
    @IBOutlet weak var globalPostDescriptionTextView: UITextView!
    @IBOutlet weak var globalCommentTextView: UITextView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var unfollowButton: UIButton!
    @IBOutlet weak var viewCommentsButton: UIButton!
    @IBOutlet weak var segueButtonForImages: UIButton!
    
    var postID = String()
    
    var post: Post? {
        didSet {
            if let post = post {
                if globalPostImageView.image == nil {
                    downloadImage(from: post.imagePath[0])
                }
                globalPostersName.text = post.addedByUser
                globalPosterUsername.text = post.username
                globalPostDescriptionTextView.text = post.description
                globalCommentTextView.text = "Leave a comment"
                postID = post.postID
            }
        }
    }
    
    
    func downloadImage(from imagePath: String) {
        let storage = storageRef.storage.reference(forURL: imagePath)
        storage.getData(maxSize: 2*1024*1024) { (data, error) in
            if error == nil {
                self.globalPostImageView.image = UIImage(data: data!)
            }
            else {
                print("Error:\(error ?? "" as! Error)")
            }
        }
    }
    @objc func onNotification(notification:Notification) {
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.tintColor = UIColor.white
                self.backgroundColor = UIColor.darkGray
                self.backgroundColorView.backgroundColor = UIColor.lightGray
                self.contentView.backgroundColor = UIColor.darkGray
            }
            else {
                self.backgroundColor = UIColor(red: 5.0/255.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.contentView.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.backgroundColorView.backgroundColor = UIColor.white
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: SettingsViewController.settingsChanged, object: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        globalCommentTextView.delegate = self
        globalCommentTextView.returnKeyType = .done
        storageRef = Storage.storage().reference()
        databaseRef = Database.database().reference()
        backgroundColorView.layer.cornerRadius = 15
        globalCommentTextView.layer.cornerRadius = 15
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: SettingsViewController.settingsChanged, object: nil)
        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Light.rawValue])
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Dark.rawValue])
        }
    }
    
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
            self.databaseRef.child(FirebaseFields.Posts.rawValue).child(postID).child("Comments").child("\(Int(Date.timeIntervalSinceReferenceDate * 1000))").setValue(textView.text)
            textView.text = "Leave a comment..."
        }
        else {
            textView.text = "Leave a comment..."
        }
        textView.resignFirstResponder()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func bookmarkPost(_ sender: Any) {
        let currentUser = databaseRef.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid)
        currentUser.child("Bookmarks").child(postID).setValue(true)
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
    }
    
    
    @IBAction func followUser(_ sender: UIButton) {
        if sender.titleLabel?.text == "Follow" {
            let currentUser = databaseRef.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid)
            currentUser.child("following").child(globalPosterUsername!.text!).setValue(true)
        }
        if sender.titleLabel?.text == "Unfollow" {
            let currentUser = databaseRef.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid)
            currentUser.child("following").child(globalPosterUsername!.text!).removeValue()
        }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        globalPostImageView.image = nil
        globalPostersName.text = ""
        globalPosterUsername.text = ""
    }

}
