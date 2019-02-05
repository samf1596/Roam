//
//  HomeTableViewController.swift
//  
//
//  Created by Samuel Fox on 11/20/18.
//

import UIKit
import Firebase
import FirebaseUI

class HomeTableViewController: UITableViewController, UIGestureRecognizerDelegate, PostTableViewCellDelegate, UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 0 && self.tableView.numberOfSections > 1 {
            let indexPath = NSIndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
        }
    }
    
    func presentInfoController(senderTag: Int, whichView: String, post: Post) {
        let alert = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Report Post", style: .destructive) { (action) in
            
            self.ref.child(FirebaseFields.Reported.rawValue).child(post.postID).child("Times").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists(){
                    print(snapshot)
                    let count = snapshot.value as! Int
                    
                    if count + 1 > 2 {
                        self.ref.child(FirebaseFields.UnderReview.rawValue).child(post.postID).setValue(true)
                    }
                    else {
                        let post = self.ref.child(FirebaseFields.Reported.rawValue).child(post.postID)
                        post.child("Times").setValue(count+1)
                    }
                }
                else {
                    let post = self.ref.child(FirebaseFields.Reported.rawValue).child(post.postID)
                    post.child("Times").setValue(1)
                }
                let currentUser = self.ref.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid)
                currentUser.child("Hidden").child(post.postID).setValue(true)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
            })
        })
        alert.addAction(UIAlertAction(title: "Hide Post", style: .destructive) { (action) in
            let currentUser = self.ref.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid)
            currentUser.child("Hidden").child(post.postID).setValue(true)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
        })
        alert.addAction(UIAlertAction(title: "Block User", style: .destructive) { (action) in
            let currentUser = self.ref.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid)
            currentUser.child("Blocked").child(post.username).setValue(true)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    func unfollowedUser(senderTag: Int) {
        let alert = UIAlertController(title: "Options", message: "You have unfollowed this user and their posts will no longer appear on your home page once the page is refreshed.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate var ref : DatabaseReference!
    fileprivate var storageRef : StorageReference!
    
    @IBOutlet var homeTableView: UITableView!
    
    let cachedImage = CachedImages()
    var tableViewSwipeUpGesture = UISwipeGestureRecognizer()
    var tableViewSwipeDownGesture = UISwipeGestureRecognizer()
    var posts = [Post]()
    var cachedPosts = [Post]()
    var hideStatusBar = false
    
    let postsModel = PostsModel.sharedInstance
    
    @objc func onNotification(notification:Notification) {
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.homeTableView.tintColor = UIColor.white
                self.homeTableView.backgroundColor = UIColor.gray
            }
            else {
                self.homeTableView.backgroundColor = UIColor(red: 5.0/255.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.homeTableView.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: SettingsViewController.settingsChanged, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: SettingsViewController.settingsChanged, object: nil)
        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Light.rawValue])
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Dark.rawValue])
        }
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(GlobalUsersTableViewController.didSwipe(_:)))
        swipeUp.direction = UISwipeGestureRecognizer.Direction.up
        swipeUp.delegate = self
        self.homeTableView.addGestureRecognizer(swipeUp)
        self.tableViewSwipeUpGesture = swipeUp
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(GlobalUsersTableViewController.didSwipe(_:)))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        swipeDown.delegate = self
        self.homeTableView.addGestureRecognizer(swipeDown)
        self.tableViewSwipeDownGesture = swipeDown
        
        navigationController?.hidesBarsOnSwipe = false
        
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        
    }

    @objc func didSwipe(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizer.Direction.down:
            hideStatusBar = false
        case UISwipeGestureRecognizer.Direction.up:
            hideStatusBar = true
        default:
            break
        }
        setNeedsStatusBarAppearanceUpdate()
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.isEqual(self.tableViewSwipeUpGesture) || gestureRecognizer.isEqual(self.tableViewSwipeDownGesture) ? true : false
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Let's roam!")
        self.tableView.isScrollEnabled = true
        postsModel.findFollowingPosts()
        postsModel.refreshContent(for: self.tableView, with: self.refreshControl)

        self.tabBarController?.delegate = self
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tableView.isScrollEnabled = false
    }
    
    
    @IBAction func refreshContent(_ sender: UIRefreshControl) {
        postsModel.findFollowingPosts()
        postsModel.refreshContent(for: self.tableView, with: self.refreshControl)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return postsModel.cachedFollowingPostsCount
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return 2.5
        }
        else {
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
        
        let imagePath = postsModel.imagePathForFollowingPost(indexPath.section, 0)
        
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            cell.globalPostFavButton.imageView?.image = UIImage(named: "bookmark-white")
            cell.viewCommentsButton.imageView?.image = UIImage(named: "comments-white")
            cell.infoButton.imageView?.image = UIImage(named: "ellipsis-white")
            cell.globalPostExperienceDetails.imageView?.image = UIImage(named: "details-white")
            cell.mapLocationButton.backgroundColor = UIColor.darkGray
            cell.mapLocationButton.setTitleColor(UIColor.white, for: .normal)
        }
        else {
            cell.globalPostFavButton.imageView?.image = UIImage(named: "bookmark")
            cell.viewCommentsButton.imageView?.image = UIImage(named: "comments")
            cell.infoButton.imageView?.image = UIImage(named: "ellipsis")
            cell.globalPostExperienceDetails.imageView?.image = UIImage(named: "details")
            cell.mapLocationButton.backgroundColor = UIColor.white
            cell.mapLocationButton.setTitleColor(UIColor.black, for: .normal)
        }
        
        let post = postsModel.postForFollowingSection(indexPath.section)
        postsModel.downloadFollowingImage(indexPath, imagePath, post.postID)

        cell.delegate = self
        cell.infoButton.tag = indexPath.section
        
        let storageImagePath = storageRef.storage.reference(forURL: post.imagePath[0])
        cell.globalPostImageView.sd_setImage(with: storageImagePath, placeholderImage: UIImage(named: "addPhoto")) //.image = postsModel.getCachedImage(post.postID+"\(0)")
        cell.post = post
        cell.globalPostExperienceDetails.tag = indexPath.section
        cell.viewCommentsButton.tag = indexPath.section
        cell.segueButtonForImages.tag = indexPath.section
        cell.unfollowButton.tag = indexPath.section
        cell.unfollowButton.layer.cornerRadius = 4.0
        cell.globalPostFavButton.layer.cornerRadius = 4.0
        cell.mapLocationButton.tag = indexPath.section
        cell.viewUserProfileButton.tag = indexPath.section
        let locationOne = Array(post.locations.keys)[0] as String
        if locationOne == "NONE" {
            cell.mapLocationButton.titleLabel?.text = ""
            cell.mapLocationButton.setTitle("", for: .normal)
            cell.mapLocationButton.isEnabled = false
        }
        else {
            cell.mapLocationButton.setTitle(locationOne, for: .normal)
            cell.mapLocationButton.isEnabled = true
        }
        
        if postsModel.postIdBookmarked(post) {
            cell.globalPostFavButton.backgroundColor = UIColor.orange//init(red: 105/255, green: 196/255, blue: 250/255, alpha: 1.0)
            cell.globalPostFavButton.imageView?.image = cell.globalPostFavButton.imageView!.image!.withRenderingMode(.alwaysTemplate)
            cell.globalPostFavButton.imageView!.tintColor = UIColor.white
        }
        else {
            cell.globalPostFavButton.backgroundColor = UIColor.clear
            cell.globalPostFavButton.imageView?.image = cell.globalPostFavButton.imageView!.image!.withRenderingMode(.alwaysTemplate)
            cell.globalPostFavButton.imageView!.tintColor = UIColor.black
        }
        if postsModel.followingUser(post) {
            cell.unfollowButton.setTitle("Unfollow", for: .normal)
        }
        else {
            cell.unfollowButton.setTitle("Follow", for: .normal)
        }
        return cell
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showHomeDetails":
            let button = sender as? UIButton
            let experienceDetailController = segue.destination as! PostExperienceDetailsTableViewController
            let postIndex = button!.tag
            let post = postsModel.postForFollowingSection(postIndex)
            self.navigationController?.navigationBar.isHidden = false
            experienceDetailController.configure(post.travels, post.experiences)
        case "showHomeComments":
            let button = sender as? UIButton
            let index = button!.tag
            let postID = postsModel.postForFollowingSection(index).postID
            let commentsViewController = segue.destination as! CommentsTableViewController
            commentsViewController.configure(postID)
        case "ShowImages":
            let viewController = segue.destination as! AllImagesTableViewController
            let index = (sender as? UIButton)?.tag
            viewController.configure(index!, "Home")
            self.navigationController?.navigationBar.isHidden = false
        case "ShowLocationOnMap":
            self.navigationController?.navigationBar.topItem?.titleView = nil
            let button = sender as? UIButton
            let postIndex = button!.tag
            let post = postsModel.postForFollowingSection(postIndex)
            let mapViewController = segue.destination as! MapViewController
            mapViewController.configure(post.locations)
        case "ShowUserProfile":
            let viewController = segue.destination as! ViewUserProfileCollectionViewController
            let index = (sender as? UIButton)?.tag
            viewController.configure(index!, "Home")
            self.navigationController?.navigationBar.isHidden = false
        default:
            assert(false, "Unhandled Segue")
        }
    }

}
