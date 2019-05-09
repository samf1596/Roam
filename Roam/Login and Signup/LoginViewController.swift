//
//  LoginViewController.swift
//  Roam
//
//  Created by Samuel Fox on 11/4/18.
//
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailLoginUser: UITextField!
    @IBOutlet weak var passwordLoginUser: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginUser(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailLoginUser.text!, password: passwordLoginUser.text!) { (user, error) in
            if error == nil {
                self.performSegue(withIdentifier: "LoginToHomeSegue", sender: self)
            }
            else{
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let cancelAlert = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAlert)
                self.present(alertController, animated: true)
            }
        }
    }
    
    @objc func onNotification(notification:Notification) {

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: SettingsViewController.settingsChanged, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailLoginUser.delegate = self
        passwordLoginUser.delegate = self
        loginButton.layer.cornerRadius = 4.0
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: SettingsViewController.settingsChanged, object: nil)
        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Light.rawValue])
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Dark.rawValue])
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard (!(textField.text?.isEmpty)!) else {return false}
        
        textField.endEditing(true)
        return true
    }
    
    func processErrors(_ textField: UITextField) {
        // Make sure input is correct
    }
    
    func processSuccess(_ textField: UITextField) {
        // Move firstResponder to next field or close if both are filled in
    }

}
