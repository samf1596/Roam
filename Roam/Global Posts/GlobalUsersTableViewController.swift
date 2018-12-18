//
//  GlobalUsersTableViewController.swift
//  
//
//  Created by Samuel Fox on 11/3/18.
//

import UIKit
import Firebase
import CoreData

class GlobalUsersTableViewController: UITableViewController, UIGestureRecognizerDelegate, UISearchBarDelegate {

    fileprivate var ref : DatabaseReference!
    fileprivate var storageRef : StorageReference!

    var tableViewSwipeUpGesture = UISwipeGestureRecognizer()
    var tableViewSwipeDownGesture = UISwipeGestureRecognizer()
    var hideStatusBar = false
    
    @IBOutlet var globalTableView: UITableView!
    
    let postsModel = PostsModel.sharedInstance
    
    @objc func onNotification(notification:Notification) {
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.globalTableView.tintColor = UIColor.white
                self.globalTableView.backgroundColor = UIColor.gray
            }
            else {
                self.globalTableView.backgroundColor = UIColor(red: 5.0/255.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.globalTableView.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: SettingsViewController.settingsChanged, object: nil)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.barStyle = .default
        searchBar.delegate = self
        searchBar.placeholder = "Search locations"
        self.navigationController?.navigationBar.topItem?.titleView = searchBar
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(GlobalUsersTableViewController.didSwipe(_:)))
        swipeUp.direction = UISwipeGestureRecognizer.Direction.up
        swipeUp.delegate = self
        self.globalTableView.addGestureRecognizer(swipeUp)
        self.tableViewSwipeUpGesture = swipeUp
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(GlobalUsersTableViewController.didSwipe(_:)))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        swipeDown.delegate = self
        self.globalTableView.addGestureRecognizer(swipeDown)
        self.tableViewSwipeDownGesture = swipeDown
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: SettingsViewController.settingsChanged, object: nil)
        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Light.rawValue])
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Dark.rawValue])
        }
        
        navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.navigationBar.topItem?.hidesSearchBarWhenScrolling = true

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
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Let's roam!")

        postsModel.refreshContent(for: self.tableView, with: self.refreshControl)

        super.viewWillAppear(animated)
    }
    
    @IBAction func refreshContent(_ sender: UIRefreshControl) {
        
        postsModel.refreshContent(for: self.tableView, with: self.refreshControl)
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return postsModel.cachedGlobalPostsCount
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

        //downloadImage(indexPath, cachedPosts[indexPath.section].imagePath)
        let imagePath = postsModel.imagePathForGlobalPost(indexPath.section, 0)
        
        let post = postsModel.postForGlobalSection(indexPath.section)
        
        postsModel.downloadGlobalImage(indexPath, imagePath, post.postID)
        
        cell.globalPostImageView.image = postsModel.getCachedImage(post.postID+"\(0)")
        cell.post = post
        cell.globalPostExperienceDetails.tag = indexPath.section
        cell.viewCommentsButton.tag = indexPath.section
        cell.segueButtonForImages.tag = indexPath.section
        cell.followButton.layer.cornerRadius = 4.0
        cell.globalPostFavButton.layer.cornerRadius = 4.0
        if postsModel.postIdBookmarked(post) {
            cell.globalPostFavButton.backgroundColor = UIColor.init(red: 105/255, green: 196/255, blue: 250/255, alpha: 1.0)
            cell.globalPostFavButton.imageView?.image = cell.globalPostFavButton.imageView!.image!.withRenderingMode(.alwaysTemplate)
            cell.globalPostFavButton.imageView!.tintColor = UIColor.white
        }
        else {
            cell.globalPostFavButton.backgroundColor = UIColor.clear
            cell.globalPostFavButton.imageView?.image = cell.globalPostFavButton.imageView!.image!.withRenderingMode(.alwaysTemplate)
            cell.globalPostFavButton.imageView!.tintColor = UIColor.black
        }
        return cell
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "ShowExperienceDetails":
                let button = sender as? UIButton
                let experienceDetailController = segue.destination as! PostExperienceDetailsTableViewController
                let postIndex = button!.tag
                let post = postsModel.postForGlobalSection(postIndex)
                self.navigationController?.navigationBar.isHidden = false
                experienceDetailController.configure(post.travels, post.experiences)
            case "ShowComments":
                let button = sender as? UIButton
                let index = button!.tag
                let postID = postsModel.postForGlobalSection(index).postID
                self.navigationController?.navigationBar.isHidden = false
                let commentsViewController = segue.destination as! CommentsTableViewController
                var comments = [String]()
                self.ref.child(FirebaseFields.Posts.rawValue).child(postID).child("Comments").observe(.value) { (snapshot) in
                    for comment in snapshot.children {
                        let _comment = (comment as? DataSnapshot)?.value as! String
                        comments.append(_comment)
                    }
                    commentsViewController.configure(comments)
                }
            case "ShowImages":
                let viewController = segue.destination as! AllImagesTableViewController
                let index = (sender as? UIButton)?.tag
                viewController.configure(index!, "Global")
                self.navigationController?.navigationBar.isHidden = false
            default:
                assert(false, "Unhandled Segue")
        }
     }

}
