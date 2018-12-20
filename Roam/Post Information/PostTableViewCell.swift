//
//  PostTableViewCell.swift
//  
//
//  Created by Samuel Fox on 11/4/18.
//

import UIKit
import Firebase

protocol PostTableViewCellDelegate {
    func presentInfoController(senderTag:Int, whichView:String)
}

class PostTableViewCell: UITableViewCell, UITextViewDelegate {

    func presentInfoController(senderTag:Int, whichView:String) {
        delegate?.presentInfoController(senderTag: senderTag, whichView: whichView)
    }
    
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
                //self.backgroundColorView.backgroundColor = UIColor.darkGray
                self.contentView.backgroundColor = UIColor.darkGray
                self.globalCommentTextView.backgroundColor = UIColor.white
                self.globalPostDescriptionTextView.backgroundColor = UIColor.gray
                self.globalPostExperienceDetails.setTitleColor(UIColor.white, for: .normal)
                self.viewCommentsButton.setTitleColor(UIColor.white, for: .normal)
                self.globalPosterUsername.textColor = UIColor.white
                self.globalPostersName.textColor = UIColor.white
                self.globalCommentTextView.keyboardAppearance = .dark
                
                self.globalPostFavButton.imageView?.image = UIImage(named: "bookmark-white")
                self.viewCommentsButton.imageView?.image = UIImage(named: "comments-white")
                self.infoButton.imageView?.image = UIImage(named: "ellipsis-white")
                self.globalPostExperienceDetails.imageView?.image = UIImage(named: "details-white")
            }
            else {
                self.backgroundColor = UIColor.white
                self.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.contentView.backgroundColor = UIColor.white
                //self.backgroundColorView.backgroundColor = UIColor.white
                self.globalCommentTextView.backgroundColor = UIColor.white
                self.globalPostDescriptionTextView.backgroundColor = UIColor.white
                self.globalPostExperienceDetails.setTitleColor(UIColor.black, for: .normal)
                self.viewCommentsButton.setTitleColor(UIColor.black, for: .normal)
                self.globalPosterUsername.textColor = UIColor.lightGray
                self.globalPostersName.textColor = UIColor.darkText
                self.globalCommentTextView.keyboardAppearance = .default
                
                self.globalPostFavButton.imageView?.image = UIImage(named: "bookmark")
                self.viewCommentsButton.imageView?.image = UIImage(named: "comments")
                self.infoButton.imageView?.image = UIImage(named: "ellipsis")
                self.globalPostExperienceDetails.imageView?.image = UIImage(named: "details")
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
        //backgroundColorView.layer.cornerRadius = 3
        globalCommentTextView.layer.cornerRadius = 3
        
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
        if globalPostFavButton.backgroundColor == UIColor.init(red: 105/255, green: 196/255, blue: 250/255, alpha: 1.0) {
            globalPostFavButton.backgroundColor = UIColor.clear
            self.globalPostFavButton.imageView?.image = UIImage(named: "bookmark")
            let currentUser = databaseRef.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid)
            currentUser.child("Bookmarks").child(postID).removeValue()
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
        }
        else {
            globalPostFavButton.backgroundColor = UIColor.init(red: 105/255, green: 196/255, blue: 250/255, alpha: 1.0)
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
    
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        presentInfoController(senderTag: sender.tag, whichView: "Fix")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        globalPostImageView.image = nil
        globalPostersName.text = ""
        globalPosterUsername.text = ""
    }

}
