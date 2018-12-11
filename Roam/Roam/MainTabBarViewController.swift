//
//  MainTabBarViewController.swift
//  Roam
//
//  Created by Samuel Fox on 12/2/18.
//  Copyright © 2018 sof5207. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    @objc func onNotification(notification:Notification) {
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.tabBar.barTintColor = UIColor.darkGray
                self.tabBar.tintColor = UIColor.white
                
                self.navigationController?.navigationBar.barStyle = .blackOpaque
                self.navigationController?.navigationBar.barTintColor = UIColor.darkGray
                self.navigationController?.navigationBar.tintColor = UIColor.white
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
                
                let proxy = UINavigationBar.appearance()
                proxy.barTintColor = UIColor.darkGray
                proxy.tintColor = UIColor.white
                proxy.barStyle = .blackOpaque
                proxy.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
                
                let buttonProxy = UIButton.appearance()
                buttonProxy.titleLabel?.textColor = UIColor.darkGray
            }
            else {
                self.tabBar.barTintColor = UIColor.white
                self.tabBar.tintColor = self.view.tintColor
                
                self.navigationController?.navigationBar.barTintColor = UIColor.white
                self.navigationController?.navigationBar.barStyle = .default
                self.navigationController?.navigationBar.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)]
                
                let proxy = UINavigationBar.appearance()
                proxy.barTintColor = UIColor.white
                proxy.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                proxy.barStyle = .default
                proxy.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)]
                
                let buttonProxy = UIButton.appearance()
                buttonProxy.titleLabel?.textColor = UIColor.white
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: SettingsViewController.settingsChanged, object: nil)
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
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
