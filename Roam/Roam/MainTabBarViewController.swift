//
//  MainTabBarViewController.swift
//  Roam
//
//  Created by Samuel Fox on 12/2/18.
//
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    // https://stackoverflow.com/questions/42135889/tabbar-icon-bounce-effect-on-selection-like-a-twitter-app-in-swift
    private var bounceAnimation: CAKeyframeAnimation = {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.2, 0.9, 1.02, 1.0]
        bounceAnimation.duration = TimeInterval(0.25)
        bounceAnimation.calculationMode = CAAnimationCalculationMode.cubic
        return bounceAnimation
    }()
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // find index if the selected tab bar item, then find the corresponding view and get its image, the view position is offset by 1 because the first item is the background (at least in this case)
        guard let index = tabBar.items?.index(of: item), tabBar.subviews.count > index + 1, let imageView = tabBar.subviews[index + 1].subviews.first as? UIImageView else {
            return
        }
        
        imageView.layer.add(bounceAnimation, forKey: nil)
    }
    
    @objc func onNotification(notification:Notification) {
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.tabBar.barTintColor = UIColor.darkGray
                self.tabBar.tintColor = UIColor.init(red: 105/255, green: 196/255, blue: 250/255, alpha: 1.0)
                
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
                self.tabBar.tintColor = UIColor.init(red: 105/255, green: 196/255, blue: 250/255, alpha: 1.0)
                
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
        
        self.selectedIndex = 1
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: SettingsViewController.settingsChanged, object: nil)
        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Light.rawValue])
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Dark.rawValue])
        }
    }

}
