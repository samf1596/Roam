//
//  ExperienceTableViewCell.swift
//  Roam
//
//  Created by Samuel Fox on 11/10/18.
//  Copyright © 2018 sof5207. All rights reserved.
//

import UIKit

class ExperienceTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var experienceTextField: UITextField!
    
    @objc func onNotification(notification:Notification) {
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.tintColor = UIColor.white
                self.backgroundColor = UIColor.darkGray
                self.textLabel?.textColor = UIColor.white
                self.textLabel?.backgroundColor = UIColor.darkGray
            }
            else {
                self.backgroundColor = UIColor(red: 5.0/255.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.textLabel?.textColor = UIColor.black
                self.textLabel?.backgroundColor = UIColor.white
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: SettingsViewController.settingsChanged, object: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: SettingsViewController.settingsChanged, object: nil)
        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Light.rawValue])
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Dark.rawValue])
        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
