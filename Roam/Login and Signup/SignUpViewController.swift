//
//  SignUpViewController.swift
//  Roam
//
//  Created by Samuel Fox on 11/4/18.
//  Copyright © 2018 sof5207. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var newUserEmail: UITextField!
    @IBOutlet weak var newUserPassword: UITextField!
    @IBOutlet weak var confirmNewUserPassword: UITextField!
    @IBOutlet weak var newUserUsername: UITextField!
    @IBOutlet weak var newUserFirstName: UITextField!
    @IBOutlet weak var newUserLastName: UITextField!
    
    @IBOutlet weak var signupButton: UIButton!
    
    fileprivate var ref : DatabaseReference!
    var keyboardVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newUserFirstName.delegate = self
        newUserLastName.delegate = self
        newUserUsername.delegate = self
        newUserEmail.delegate = self
        newUserPassword.delegate = self
        confirmNewUserPassword.delegate = self
        ref = Database.database().reference()
        self.title = "Signup for Roam!"
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
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.view.tintColor = UIColor.white
                self.view.backgroundColor = UIColor.darkGray
            }
            else {
                self.view.backgroundColor = UIColor(red: 5.0/255.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.view.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: SettingsViewController.settingsChanged, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name:
            UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func registerUser(_ sender: Any) {
        Auth.auth().createUser(withEmail: newUserEmail.text!, password: newUserPassword.text!) { (user, error) in
            if error == nil {
                
                let firstname = self.newUserFirstName.text!
                let lastname = self.newUserLastName.text!
                let username = self.newUserUsername.text!
                let email = user?.email
                let userId = user?.uid
                let newUser = NewUser(firstname: firstname, lastname: lastname, username: username, uid: userId!, email: email!)
                
                self.ref.child("Accounts").child(userId!).setValue(newUser.toObject());
                
                self.performSegue(withIdentifier: "SignupToHomeSegue", sender: self)
            }
            else{
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let cancelAlert = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAlert)
                self.present(alertController, animated: true)
            }
        }
        
    }
    
    @objc func keyboardWillShow(notification:Notification) {
        if !keyboardVisible && ( self.view.traitCollection.horizontalSizeClass != UIUserInterfaceSizeClass.regular ) {
            let userInfo = notification.userInfo!
            let keyboardSize = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect
            if self.view.frame.origin.y == 0 && (newUserPassword.isEditing || confirmNewUserPassword.isEditing) {
                self.view.frame.origin.y -= keyboardSize!.height/4
            }
        }
        
        keyboardVisible = true
    }
    
    @objc
    func keyboardWillHide(notification:Notification) {
        if keyboardVisible && ( self.view.traitCollection.horizontalSizeClass != UIUserInterfaceSizeClass.regular ) {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y = 0
            }
        }
        keyboardVisible = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard (!(textField.text?.isEmpty)!) else {return false}
        
        textField.endEditing(true)
        return true
    }
    
    // TODO: process going to next fields or errors if text is not acceptable
    func processErrors(_ textField: UITextField) {
        
    }
    
    func processSuccess(_ textField: UITextField) {
        
    }

}
