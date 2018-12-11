//
//  ProfileCollectionViewCell.swift
//  Roam
//
//  Created by Samuel Fox on 11/21/18.
//  Copyright © 2018 sof5207. All rights reserved.
//

import UIKit
import Firebase
class ProfileCollectionViewCell: UICollectionViewCell {
    
    fileprivate var storageRef : StorageReference!
    fileprivate var downloadImageTask : StorageDownloadTask!
    fileprivate var databaseRef : DatabaseReference!
    
    @objc func onNotification(notification:Notification) {
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.tintColor = UIColor.white
                self.backgroundColor = UIColor.darkGray
            }
            else {
                self.backgroundColor = UIColor.white
                self.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: SettingsViewController.settingsChanged, object: nil)
    }
    
    @IBOutlet weak var postImageView: UIImageView!
    var post: Post? {
        didSet {
            if let post = post {
                if postImageView.image == nil {
                    downloadImage(from: post.imagePath[0])
                }
            }
        }
    }
    
    func downloadImage(from imagePath: String) {
        let storage = storageRef.storage.reference(forURL: imagePath)
        storage.getData(maxSize: 2*1024*1024) { (data, error) in
            if error == nil {
                self.postImageView.image = UIImage(data: data!)
            }
            else {
                print("Error:\(error ?? "" as! Error)")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        storageRef = Storage.storage().reference()
        databaseRef = Database.database().reference()
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: SettingsViewController.settingsChanged, object: nil)
        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Light.rawValue])
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Dark.rawValue])
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.image = nil
    }
    
}
