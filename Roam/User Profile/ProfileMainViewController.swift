//
//  ProfileMainViewController.swift
//  Roam
//
//  Created by Samuel Fox on 12/1/18.
//

import UIKit
import Firebase

protocol MainViewDelegate {
    func toggleCollectionViewType(show collection: String)
}

class ProfileMainViewController: UIViewController, ShowPostDelegate {

    var delegate : MainViewDelegate?
    var pageTitle = String()
    
    var postToShow : Post?
    var cellSelected : Int?
    
    func showPost(show post: Post, selected cell: Int) {
        self.postToShow = post
        self.cellSelected = cell
        performSegue(withIdentifier: "ShowProfilePost", sender: self)
    }
    
    @objc func onNotification(notification:Notification) {
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.view.tintColor = UIColor.white
                self.view.backgroundColor = UIColor.darkGray
                self.segmentedControl.backgroundColor = UIColor.darkGray
                self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
                self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .normal)
                self.segmentedControl.tintColor = UIColor.init(red: 105/255, green: 196/255, blue: 250/255, alpha: 1.0)
                self.navigationController?.navigationBar.tintColor = UIColor.init(red: 105/255, green: 196/255, blue: 250/255, alpha: 1.0)
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.orange]
            }
            else {
                self.view.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.view.backgroundColor = UIColor.white
                self.segmentedControl.backgroundColor = UIColor.white
                self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
                self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(red: 105/255, green: 196/255, blue: 250/255, alpha: 1.0)], for: .normal)
                self.segmentedControl.tintColor = UIColor.init(red: 105/255, green: 196/255, blue: 250/255, alpha: 1.0)
                self.navigationController?.navigationBar.tintColor = UIColor.init(red: 105/255, green: 196/255, blue: 250/255, alpha: 1.0)
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.orange]
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: SettingsViewController.settingsChanged, object: nil)
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    fileprivate var ref : DatabaseReference!
    
    let postModel = PostsModel.sharedInstance
    
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
            postModel.clearFollowingUsersAndBookmarks()
        }
        catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.error)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initial
    }
    
    @IBAction func segmentControlAction(_ sender: UISegmentedControl) {
        var collection = String()
        if sender.selectedSegmentIndex == 0 {
            collection = "UsersPosts"
        }
        else {
            collection = "BookmarkedPosts"
        }
        delegate?.toggleCollectionViewType(show: collection)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: SettingsViewController.settingsChanged, object: nil)
        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Light.rawValue])
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Dark.rawValue])
        }
        ref = Database.database().reference()
        
        if Auth.auth().currentUser != nil && pageTitle.count < 1 {
            ref.child(FirebaseFields.Accounts.rawValue).child(Auth.auth().currentUser!.uid).observe(.value) { (snapshot) in
                
                let user = NewUser(snapshot: snapshot)
                self.pageTitle = user.firstname
                self.navigationController?.navigationBar.topItem?.title = self.pageTitle
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "presentCollectionView":
            let controller = segue.destination as! ProfileViewController
            self.delegate = controller // in order to toggle which collection view is being shown
            
            controller.delegate = self // to show the post the is selected in the collection view
        case "settings":
            _ = segue.destination as! SettingsViewController
        case "ShowProfilePost":
            let controller = segue.destination as! ProfilePostViewController
            var usersPosts = true
            if segmentedControl.selectedSegmentIndex == 1 {
                usersPosts = false
            }
            controller.configure(self.postToShow!, self.cellSelected!, usersPosts)
        default:
            assert(false, "Unhandled Segue")
        }
    }
    

}
