//
//  FirstViewController.swift
//  Roam
//
//  Created by Samuel Fox on 11/4/18.
//
//

import UIKit
import FirebaseAuth

class FirstViewController: UIViewController {
    
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Roam"
        _ = PostsModel.sharedInstance
        loginButton.layer.cornerRadius = 4.0
        signupButton.layer.cornerRadius = 4.0
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
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        if Auth.auth().currentUser != nil {
            _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(dataLoaded), userInfo: nil, repeats: false)
        }
    }
    
    @objc func dataLoaded() {
        self.performSegue(withIdentifier: "AlreadySignedInSegue", sender: nil)
    }

}
