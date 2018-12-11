//
//  LoadingScreenViewController.swift
//  Roam
//
//  Created by Samuel Fox on 12/8/18.
//  Copyright © 2018 sof5207. All rights reserved.
//

import UIKit
import Firebase
class LoadingScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Roam"
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: SettingsViewController.settingsChanged, object: nil)
        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Light.rawValue])
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Dark.rawValue])
        }
    }
    
    @objc func onNotification(notification:Notification) {
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.view.tintColor = UIColor.white
                self.view.backgroundColor = UIColor.darkGray
                
                let proxy = UINavigationBar.appearance()
                proxy.barTintColor = UIColor.darkGray
                proxy.tintColor = UIColor.white
                proxy.barStyle = .blackOpaque
                proxy.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
                
                let buttonProxy = UIButton.appearance()
                buttonProxy.titleLabel?.textColor = UIColor.darkGray
            }
            else {
                self.view.backgroundColor = UIColor(red: 60.0/255.0, green: 198.0/255.0, blue: 1.0, alpha: 1.0)
                self.view.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            _ = Timer.scheduledTimer(timeInterval: 1.75, target: self, selector: #selector(dataLoaded), userInfo: nil, repeats: false)
        }
        else {
            _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(signInPage), userInfo: nil, repeats: false)
        }
    }
    
    @objc func dataLoaded() {
        self.performSegue(withIdentifier: "AlreadySignedInSegue", sender: nil)
    }
    
    @objc func signInPage() {
        self.performSegue(withIdentifier: "FirstViewController", sender: nil)
    }

}
