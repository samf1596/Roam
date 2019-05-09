//
//  CommentsTableViewController.swift
//  Roam
//
//  Created by Samuel Fox on 11/28/18.
//

import UIKit
import FirebaseDatabase

class CommentsTableViewController: UITableViewController {
    
    fileprivate var ref : DatabaseReference!
    var postID = String()
    var comments = [String]()
    
    @objc func onNotification(notification:Notification) {
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.tableView.tintColor = UIColor.white
                self.tableView.backgroundColor = UIColor.darkGray
                self.tableView.tableHeaderView?.backgroundColor = UIColor.lightGray
            }
            else {
                self.tableView.backgroundColor = UIColor(red: 5.0/255.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.tableView.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.tableView.tableHeaderView?.backgroundColor = UIColor.white
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: SettingsViewController.settingsChanged, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200

        ref = Database.database().reference()
        
        self.ref.child(FirebaseFields.Posts.rawValue).child(postID).child("Comments").observe(.value) { (snapshot) in
            self.comments = []
            for comment in snapshot.children {
                let _comment = (comment as? DataSnapshot)?.value as! String
                self.comments.append(_comment)
            }
            self.tableView.reloadData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: SettingsViewController.settingsChanged, object: nil)
        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Light.rawValue])
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Dark.rawValue])
        }
    }

    // MARK: - Table view data source
    func configure(_ postID: String) {
        self.postID = postID
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Comment", for: indexPath) as! CommentsTableViewCell

        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            cell.commentText.textColor = UIColor.black
            cell.commentText.backgroundColor = UIColor.white
            cell.backgroundColor = UIColor.white
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            cell.commentText.textColor = UIColor.white
            cell.commentText.backgroundColor = UIColor.darkGray
            cell.backgroundColor = UIColor.darkGray
        }
        print(comments[indexPath.row])
        cell.commentText.text = comments[indexPath.row]
        
        cell.adjustTextViewHeight(textview: cell.commentText)
        
        return cell
    }

}
