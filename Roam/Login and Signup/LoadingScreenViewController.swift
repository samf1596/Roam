//
//  LoadingScreenViewController.swift
//  Roam
//
//  Created by Samuel Fox on 12/8/18.
//
//

import UIKit
import Firebase
class LoadingScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Roum"
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: SettingsViewController.settingsChanged, object: nil)
        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Light.rawValue])
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Dark.rawValue])
        }
    }
    
    @objc func onNotification(notification:Notification) {

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
