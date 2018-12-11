//
//  SettingsViewController.swift
//  Roam
//
//  Created by Samuel Fox on 12/2/18.
//  Copyright © 2018 sof5207. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var clearCacheButton: UIButton!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    static let settingsChanged = Notification.Name("settingsChanged")
    
    @objc func onNotification(notification:Notification) {
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.view.tintColor = UIColor.white
                self.view.backgroundColor = UIColor.darkGray
                
                self.navigationController?.navigationBar.barTintColor = UIColor.darkGray
                self.navigationController?.navigationBar.tintColor = UIColor.white
                self.navigationController?.navigationBar.barStyle = .blackOpaque
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
                self.view.backgroundColor = UIColor.white
                self.view.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                
                self.navigationController?.navigationBar.barTintColor = UIColor.white
                self.navigationController?.navigationBar.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.navigationController?.navigationBar.barStyle = .default
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
        clearCacheButton.layer.cornerRadius = 4.0
        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            darkModeSwitch.isOn = false
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Light.rawValue])
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            darkModeSwitch.isOn = true
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Dark.rawValue])
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            darkModeSwitch.isOn = false
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            darkModeSwitch.isOn = true
        }
    }
    
    @IBAction func clearCacheAction(_ sender: Any) {
        let generator = UINotificationFeedbackGenerator()
        
        let fileManager = FileManager()
        
        let directoryPath = NSHomeDirectory().appending("/Library/Caches/")
        if fileManager.fileExists(atPath: directoryPath) {
            do {
                let filePaths = try fileManager.contentsOfDirectory(atPath: directoryPath)
                for filePath in filePaths {
                    if filePath.hasSuffix(".jpg"){
                        print(filePath)
                        try fileManager.removeItem(atPath: directoryPath + filePath)
                    }
                }
                let alertView = UIAlertController(title: "All Clear", message: "Successfully cleared cache", preferredStyle: .alert)
                let clearedCache = UIAlertAction(title: "OK", style: .cancel)
                alertView.addAction(clearedCache)
                self.present(alertView, animated: true, completion: nil)
                
                generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
            }
            catch{
                let alertView = UIAlertController(title: "Uh Oh", message: "\(error)", preferredStyle: .alert)
                let clearedCache = UIAlertAction(title: "OK", style: .cancel)
                alertView.addAction(clearedCache)
                self.present(alertView, animated: true, completion: nil)
                
                generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.error)
            }
        }
        
    }
    
    @IBAction func enableDarkMode(_ sender: UISwitch) {
        if sender.isOn {
            
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Dark.rawValue])
            UserDefaults.standard.set(true, forKey: "DarkMode")
            
            let proxy = UINavigationBar.appearance()
            proxy.barTintColor = UIColor.darkGray
            proxy.tintColor = UIColor.white
            proxy.barStyle = .blackOpaque
            proxy.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
            
        }
        else {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Light.rawValue])
            UserDefaults.standard.set(false, forKey: "DarkMode")
            
            let proxy = UINavigationBar.appearance()
            proxy.barTintColor = UIColor.white
            proxy.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
            proxy.barStyle = .default
            proxy.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)]
        }
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
