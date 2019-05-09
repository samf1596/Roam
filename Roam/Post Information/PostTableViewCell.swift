//
//  PostTableViewCell.swift
//  
//
//  Created by Samuel Fox on 11/4/18.
//

import UIKit
import Firebase

protocol PostTableViewCellDelegate {
    func presentInfoController(senderTag:Int, whichView:String, post: Post)
    func unfollowedUser(senderTag:Int)
}

class PostTableViewCell: UITableViewCell, UITextViewDelegate {

    // MARK: delegate functions for presenting info button and unfollowing user
    func presentInfoController(senderTag:Int, whichView:String, post: Post) {
        delegate?.presentInfoController(senderTag: senderTag, whichView: whichView, post: post)
    }
    func unfollowedUser(senderTag:Int) {
        delegate?.unfollowedUser(senderTag: senderTag)
    }
    
    // MARK: variable declarations
    var delegate : PostTableViewCellDelegate?
    
    fileprivate var storageRef : StorageReference!
    fileprivate var downloadImageTask : StorageDownloadTask!
    fileprivate var databaseRef : DatabaseReference!
    
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
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var mapLocationButton: UIButton!
    @IBOutlet weak var viewUserProfileButton: UIButton!
    
    @IBOutlet weak var imageCountLabel: UILabel!
    @IBAction func viewUserProfileAction(_ sender: Any) {
        print("did something")
    }
    
    var postID = String()
    
    // MARK: set post information
    var post: Post? {
        // make sure that the post's information has been updated once assigned
        didSet {
            if let post = post {
                globalPostersName.text = post.addedByUser
                globalPosterUsername.text = post.username
                globalPostDescriptionTextView.text = post.description == "NOTEXT" ? "" : post.description
                globalCommentTextView.text = "Leave a comment"
                postID = post.postID
                imageCountLabel.text = "+ " + String(post.imagePath.count-1)
                let locationOne = Array(post.locations.keys)[0] as String
                if locationOne == "NONE" {
                    mapLocationButton.setTitle("", for: .normal)
                }
                else {
                    mapLocationButton.setTitle(locationOne, for: .normal)
                }
            }
        }
    }
    
    // MARK: theme information
    @objc func onNotification(notification:Notification) {
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.tintColor = UIColor.white
                self.backgroundColor = UIColor.darkGray
                self.contentView.backgroundColor = UIColor.darkGray
                self.globalCommentTextView.backgroundColor = UIColor.white
                self.globalPostDescriptionTextView.backgroundColor = UIColor.gray
                self.globalPostExperienceDetails.setTitleColor(UIColor.white, for: .normal)
                self.viewCommentsButton.setTitleColor(UIColor.white, for: .normal)
                self.globalPosterUsername.textColor = UIColor.white
                self.globalPostersName.textColor = UIColor.white
                self.globalCommentTextView.keyboardAppearance = .dark
                self.globalPostFavButton.setImage(UIImage(named: "bookmark-white"), for: .normal)
                self.viewCommentsButton.setImage(UIImage(named: "comments-white"), for: .normal)
                self.infoButton.setImage(UIImage(named: "ellipsis-white"), for: .normal)
                self.globalPostExperienceDetails.setImage(UIImage(named: "details-white"), for: .normal)
                
                mapLocationButton.backgroundColor = UIColor.darkGray
                mapLocationButton.setTitleColor(UIColor.white, for: .normal)
            }
            else {
                self.backgroundColor = UIColor.white
                self.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.contentView.backgroundColor = UIColor.white
                self.globalCommentTextView.backgroundColor = UIColor.white
                self.globalPostDescriptionTextView.backgroundColor = UIColor.white
                self.globalPostExperienceDetails.setTitleColor(UIColor.black, for: .normal)
                self.viewCommentsButton.setTitleColor(UIColor.black, for: .normal)
                self.globalPosterUsername.textColor = UIColor.lightGray
                self.globalPostersName.textColor = UIColor.darkText
                self.globalCommentTextView.keyboardAppearance = .default
                self.globalPostFavButton.setImage(UIImage(named: "bookmark"), for: .normal)
                self.viewCommentsButton.setImage(UIImage(named: "comments"), for: .normal)
                self.infoButton.setImage(UIImage(named: "ellipsis"), for: .normal)
                self.globalPostExperienceDetails.setImage(UIImage(named: "details"), for: .normal)
                
                mapLocationButton.backgroundColor = UIColor.white
                mapLocationButton.setTitleColor(UIColor.black, for: .normal)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: SettingsViewController.settingsChanged, object: nil)
    }
    
    // MARK: cell is alive
    override func awakeFromNib() {
        super.awakeFromNib()
        globalPosterUsername.isHidden  = true
        globalCommentTextView.delegate = self
        globalCommentTextView.returnKeyType = .done
        storageRef = Storage.storage().reference()
        databaseRef = Database.database().reference()
        globalCommentTextView.layer.cornerRadius = 3
        imageCountLabel.layer.masksToBounds = true
        imageCountLabel.layer.cornerRadius = 5
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

    // MARK: allow user to bookmark post. Update views accordingly
    @IBAction func bookmarkPost(_ sender: Any) {
        if globalPostFavButton.backgroundColor == UIColor.orange {
            globalPostFavButton.backgroundColor = UIColor.clear
            if UserDefaults.standard.bool(forKey: "DarkMode") == false {
                self.globalPostFavButton.setImage(UIImage(named: "bookmark"), for: .normal)
                self.globalPostFavButton.setImage(UIImage(named: "bookmark"), for: .selected)
            }
            else {
                self.globalPostFavButton.setImage(UIImage(named: "bookmark-white"), for: .normal)
                self.globalPostFavButton.setImage(UIImage(named: "bookmark-white"), for: .selected)
            }
            let currentUser = databaseRef.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid)
            currentUser.child("Bookmarks").child(postID).removeValue()
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
        }
        else {
            globalPostFavButton.backgroundColor = UIColor.orange
            UIView.animate(withDuration: 0.1, delay: 0.0,
                           options: [AnimationOptions.curveEaseInOut], animations: {
                self.globalPostFavButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }) { (true) in
                self.globalPostFavButton.transform = CGAffineTransform.identity
                self.globalPostFavButton.imageView?.image = UIImage(named: "bookmark-white")
            }
            let currentUser = databaseRef.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid)
            currentUser.child("Bookmarks").child(postID).setValue(true)
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
        }
    }
    
    // MARK: allow user to follow another. Update views accordingly
    @IBAction func followUser(_ sender: UIButton) {
        if sender.titleLabel?.text == "Follow" {
            let currentUser = databaseRef.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid)
            currentUser.child("following").child(globalPosterUsername!.text!).setValue(true)
            sender.setTitle("Unfollow", for: .normal)
        }
        if sender.titleLabel?.text == "Unfollow" {
            let currentUser = databaseRef.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid)
            currentUser.child("following").child(globalPosterUsername!.text!).removeValue()
            sender.setTitle("Follow", for: .normal)
            unfollowedUser(senderTag:sender.tag)
        }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
    }
    
    // MARK: present info controller
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        presentInfoController(senderTag: sender.tag, whichView: "Fix", post: post!)
    }
    
    // MARK: clear old info when this cell dies
    override func prepareForReuse() {
        super.prepareForReuse()
        globalPostImageView.image = nil
        globalPostersName.text = ""
        globalPosterUsername.text = ""
    }

}
