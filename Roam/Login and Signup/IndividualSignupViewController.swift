//
//  IndividualSignupViewController.swift
//  Roam
//
//  Created by Samuel Fox on 1/24/19.
//  Copyright © 2019 sof5207. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class IndividualSignupViewController: UIViewController, UITextFieldDelegate {

    fileprivate var ref : DatabaseReference!
    
    @IBOutlet weak var infoTextField: UITextField!
    var keyboardVisible = false
    var previousInfo = [String:String]()
    
    func configure(_ informationType: String, _ information: String, _ previousInfo: [String:String]) {
        self.previousInfo = previousInfo
        self.previousInfo.updateValue(information, forKey: informationType)
    }
    
    func registerUser() {
        Auth.auth().createUser(withEmail: previousInfo["EmailAddress"]!, password: previousInfo["Password"]!) { (user, error) in
            if error == nil {
                
                let firstname = self.previousInfo["FirstName"]!
                let lastname = self.previousInfo["LastName"]!
                let username = ""
                let email = user?.user.email
                let userId = user?.user.uid
                let newUser = NewUser(firstname: firstname, lastname: lastname, username: username, uid: userId!, email: email!)
                
                self.ref.child("Accounts").child(userId!).setValue(newUser.toObject());
                
                self.performSegue(withIdentifier: "SignupToHomeSegue", sender: self)
            }
            else{
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let cancelAlert = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAlert)
                self.present(alertController, animated: true)
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        
        infoTextField.delegate = self
        infoTextField.becomeFirstResponder()
        
        self.title = "Signup for Roam!"
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
                print("")
            }
            else {
                print("")
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: SettingsViewController.settingsChanged, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name:
            UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification:Notification) {
        /*
        if !keyboardVisible && ( self.view.traitCollection.horizontalSizeClass != UIUserInterfaceSizeClass.regular ) {
            let userInfo = notification.userInfo!
            let keyboardSize = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize!.height/2
            }
        }
        
        keyboardVisible = true
         */
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
        switch textField.tag {
            case 0:
                performSegue(withIdentifier: "ToLastName", sender: self)
            case 1:
                performSegue(withIdentifier: "ToEmailAddress", sender: self)
            case 2:
                performSegue(withIdentifier: "ToPassword", sender: self)
            case 3:
                performSegue(withIdentifier: "ToConfirmPassword", sender: self)
            case 4:
                registerUser()
            default:
                assert(false, "Unhandled Text Field Tag")
        }
        return true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "ToLastName":
                let destination = segue.destination as! IndividualSignupViewController
                destination.configure("FirstName", infoTextField.text!, previousInfo)
            case "ToEmailAddress":
                let destination = segue.destination as! IndividualSignupViewController
                destination.configure("LastName", infoTextField.text!, previousInfo)
            case "ToPassword":
                let destination = segue.destination as! IndividualSignupViewController
                destination.configure("EmailAddress", infoTextField.text!, previousInfo)
            case "ToConfirmPassword":
                let destination = segue.destination as! IndividualSignupViewController
                destination.configure("Password", infoTextField.text!, previousInfo)
            case "SignupToHomeSegue":
                let _ = segue.destination
            default:
                assert(false, "Unhandled Segue")
        }
    }

}