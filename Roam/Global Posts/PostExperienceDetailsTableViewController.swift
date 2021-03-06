//
//  PostExperienceDetailsTableViewController.swift
//  Roam
//
//  Created by Samuel Fox on 11/11/18.
//
//

import UIKit

class PostExperienceDetailsTableViewController: UITableViewController {
    
    var travels = [String]()
    var experiences = [String]()
    
    func configure(_ travels: [String], _ experiences: [String]) {
        self.travels = travels
        self.experiences = experiences
    }
    
    @objc func onNotification(notification:Notification) {
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.tableView.tintColor = UIColor.white
                self.tableView.backgroundColor = UIColor.darkGray
            }
            else {
                self.tableView.backgroundColor = UIColor(red: 5.0/255.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.tableView.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: SettingsViewController.settingsChanged, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = false
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if experiences.count > 0 && experiences[0] != "" {
                return experiences.count
            }
            return 0
        }
        else if section == 1 {
            if travels.count > 0 && travels[0] != "" {
                return travels.count
            }
            return 0
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Experiences"
        }
        if section == 1 {
            return "Travels"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Detail", for: indexPath) as! CommentsTableViewCell

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
        
        if indexPath.section == 0 {
            cell.commentText.text = experiences[indexPath.row]
        }
        if indexPath.section == 1 {
            cell.commentText.text = travels[indexPath.row]
        }
        
        cell.adjustTextViewHeight(textview: cell.commentText)
        
        return cell
    }

}
