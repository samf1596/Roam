//
//  ExperiencesTableViewController.swift
//  Roam
//
//  Created by Samuel Fox on 11/8/18.
//
//

import UIKit

protocol ExperiencesDelegate {
    func saveExperiences(_ experiences: [String])
}

class ExperiencesTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var experiencesTableView: UITableView!
    var isAdding = false
    var delegate: ExperiencesDelegate?
    let model = Experiences.sharedExperiencesInstance
    
    struct TaskSection {
        static let tasks = 1
        static let add = 2
    }
    
    @objc func onNotification(notification:Notification) {
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.tableView.tintColor = UIColor.white
                self.tableView.backgroundColor = UIColor.darkGray
                self.tableView.tableHeaderView?.backgroundColor = UIColor.lightGray
            }
            else {
                self.tableView.backgroundColor = UIColor(red: 5.0/255.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.tableView.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.tableView.tableHeaderView?.backgroundColor = UIColor.white
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
    }

    @IBAction func doneAdding(_ sender: Any) {
        delegate?.saveExperiences(model.experiences)
        model.experiences = [String]()
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
        performSegue(withIdentifier: "goBackToUpload", sender: self)
    }
    
    @IBAction func addExperience(_ sender: Any) {
        isAdding = !isAdding
        experiencesTableView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        isAdding = false
        
        guard let text = textField.text else {return true}
        
        if text.isEmpty {
            tableView.reloadData()
        }
        else {
            model.addExperience(text)
            textField.text = ""
            tableView.reloadData()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
        }
        return true
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return isAdding ? 3 : 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Add some things that you did..."
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 0
        case TaskSection.tasks:
            return model.experiencesCount
        case TaskSection.add:
            return 1
        default:
            assert(false, "Unhandled Section Number")
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
        case TaskSection.tasks:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Experience", for: indexPath) as! DetailsTableViewCell
            cell.detailTextView.text = model.experienceAtIndex(indexPath.row)
            cell.adjustTextViewHeight(textview: cell.detailTextView)
            return cell
        case TaskSection.add:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddExperience", for: indexPath) as! ExperienceTableViewCell
            return cell
        default:
            assert(false, "Unhandled Section Number")
        }
        return tableView.dequeueReusableCell(withIdentifier: "Experience", for: indexPath)
    }
 
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.section != 0 {
            return .delete
        }
        return .none
    }
    
    
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section != 0 {
            return true
        } else {
            return false
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            model.deleteExperienceAtIndex(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }

}
