//
//  CommentsTableViewController.swift
//  Roam
//
//  Created by Samuel Fox on 11/28/18.
//  Copyright © 2018 sof5207. All rights reserved.
//

import UIKit

class CommentsTableViewController: UITableViewController {

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
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: SettingsViewController.settingsChanged, object: nil)
        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Light.rawValue])
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Dark.rawValue])
        }
    }

    // MARK: - Table view data source
    func configure(_ comments: [String]) {
        self.comments = comments
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Comment", for: indexPath)

        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            cell.textLabel?.textColor = UIColor.black
            cell.textLabel?.backgroundColor = UIColor.white
            cell.backgroundColor = UIColor.white
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            cell.textLabel?.textColor = UIColor.white
            cell.textLabel?.backgroundColor = UIColor.darkGray
            cell.backgroundColor = UIColor.darkGray
        }
        
        cell.textLabel?.text = comments[indexPath.row]

        return cell
    }

}
