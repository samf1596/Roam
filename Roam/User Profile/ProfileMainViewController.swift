//
//  ProfileMainViewController.swift
//  Roam
//
//  Created by Samuel Fox on 12/1/18.
//  Copyright © 2018 sof5207. All rights reserved.
//

import UIKit
import Firebase

protocol MainViewDelegate {
    func toggleCollectionViewType(show collection: String)
}

class ProfileMainViewController: UIViewController {

    var delegate : MainViewDelegate?
    var pageTitle = String()
    
    @objc func onNotification(notification:Notification) {
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.view.tintColor = UIColor.white
                self.view.backgroundColor = UIColor.darkGray
                self.segmentedControl.backgroundColor = UIColor.darkGray
                self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.black], for: .selected)
                self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .normal)
            }
            else {
                self.view.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.view.backgroundColor = UIColor.white
                self.segmentedControl.backgroundColor = UIColor.white
                self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
                self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)], for: .normal)
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
                self.title = self.pageTitle
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "presentCollectionView":
            let controller = segue.destination as! ProfileViewController
            self.delegate = controller
            
        case "settings":
            _ = segue.destination as! SettingsViewController
        default:
            assert(false, "Unhandled Segue")
        }
    }
    

}
