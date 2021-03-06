//
//  ViewUserProfileCollectionViewController.swift
//  Roam
//
//  Created by Samuel Fox on 1/31/19.
//
//

import UIKit
import Firebase

class ViewUserProfileCollectionViewController: UICollectionViewController {

    fileprivate var ref : DatabaseReference!
    fileprivate var storageRef : StorageReference!
    
    @objc func onNotification(notification:Notification) {
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.view.tintColor = UIColor.white
                self.view.backgroundColor = UIColor.darkGray
                self.collectionView.backgroundView?.backgroundColor = UIColor.darkGray
                self.collectionView.backgroundColor = UIColor.darkGray
            }
            else {
                self.view.backgroundColor = UIColor.white
                self.view.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.collectionView.backgroundView?.backgroundColor = UIColor.white
                self.collectionView.backgroundColor = UIColor.white
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: SettingsViewController.settingsChanged, object: nil)
    }
    
    let postModel = PostsModel.sharedInstance
    var cellSelected = IndexPath()
    
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

        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: SettingsViewController.settingsChanged, object: nil)
        
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Dark.rawValue])
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Light.rawValue])
        }

        collectionView.dataSource = self
        collectionView.delegate = self
        
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            switch segue.identifier {
            case "ShowPost":
                let controller = segue.destination as! ProfilePostViewController
                let post = (sender as! ProfileCollectionViewCell).post
                
                controller.configure(post!, self.cellSelected.row, false, true)
            default:
                assert(false, "Unhandled Segue")
            }
    }
 

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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.cellSelected = indexPath
        let cell = collectionView.cellForItem(at: indexPath) as! ProfileCollectionViewCell
        self.performSegue(withIdentifier: "ShowPost", sender: cell)
    }

}
