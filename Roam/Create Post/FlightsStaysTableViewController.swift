//
//  FlightsStaysTableViewController.swift
//  
//
//  Created by Samuel Fox on 11/8/18.
//

import UIKit

protocol TravelDelegate {
    func saveTravels(_ travels: [String])
}

class FlightsStaysTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var travelTableView: UITableView!
    var isAdding = false
    var delegate: TravelDelegate?
    let model = TravelInfo.sharedTravelsInstance
    
    struct TaskSection {
        static let tasks = 0
        static let add = 1
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
        delegate?.saveTravels(model.travels)
        model.travels = [String]()
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
        performSegue(withIdentifier: "goBackToUpload", sender: self)
    }
    
    @IBAction func addTravel(_ sender: Any) {
        isAdding = !isAdding
        travelTableView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        isAdding = false
        
        guard let text = textField.text else {return true}
        
        if text.isEmpty {
            tableView.reloadData()
        }
        else {
            model.addTravel(text)
            textField.text = ""
            tableView.reloadData()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
        }
        return true
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return isAdding ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case TaskSection.tasks:
            return model.travelsCount
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "Travel", for: indexPath)
            cell.textLabel?.text = model.travelAtIndex(indexPath.row)
            return cell
        case TaskSection.add:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddTravel", for: indexPath) as! ExperienceTableViewCell
            return cell
        default:
            assert(false, "Unhandled Section Number")
        }
        return tableView.dequeueReusableCell(withIdentifier: "Travel", for: indexPath)
    }
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            model.deleteTravelAtIndex(indexPath.row)
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
