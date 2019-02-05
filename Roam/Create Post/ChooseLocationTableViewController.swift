//
//  ChooseLocationTableViewController.swift
//  Roam
//
//  Created by Samuel Fox on 12/18/18.
//  Copyright © 2018 sof5207. All rights reserved.
//

import UIKit
import MapKit

protocol ChooseLocationDelegate {
    func saveChosenLocations(_ locations: [MKMapItem])
}

class ChooseLocationTableViewController: UITableViewController, UISearchBarDelegate {

    var delegate: ChooseLocationDelegate?
    var locationsToDisplay = [MKMapItem]()
    var locationsSelected = [MKMapItem]()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            delegate?.saveChosenLocations(locationsSelected)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.barStyle = .default
        searchBar.delegate = self
        searchBar.placeholder = "Search locations"
        self.navigationItem.titleView = searchBar
        
    }
    
    func configure(_ locations: [MKMapItem]) {
        locationsSelected = locations
    }

    // Parse function adapted from https://www.thorntech.com/2016/01/how-to-search-for-location-using-apples-mapkit/
    func parseAddress(selectedItem:MKPlacemark) -> String {

        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between [street] and [city state]
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between city and state
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchBarText = searchBar.text
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        //request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.locationsToDisplay = response.mapItems
            self.tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchBarText = searchBar.text
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        //request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.locationsToDisplay = response.mapItems
            self.tableView.reloadData()
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.locationsToDisplay = []
        self.tableView.reloadData()
        searchBar.showsCancelButton = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Selected Locations"
        }
        if section == 1 {
            return "Location Options"
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return locationsSelected.count
        }
        if section == 1 {
            return locationsToDisplay.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "location", for: indexPath) as! LocationTableViewCell

        if indexPath.section == 0 {
            let selectedItem = locationsSelected[indexPath.row].placemark
            cell.textLabel?.text = selectedItem.name
            cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
            cell.location = locationsSelected[indexPath.row]
        }
        if indexPath.section == 1 {
            let selectedItem = locationsToDisplay[indexPath.row].placemark
            cell.textLabel?.text = selectedItem.name
            cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
            cell.location = locationsToDisplay[indexPath.row]
        }
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let cell = tableView.cellForRow(at: indexPath) as! LocationTableViewCell
            if cell.location != nil && !locationsSelected.contains(cell.location!) {
                locationsSelected.append(cell.location!)
            }
            tableView.reloadData()
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == 0 {
            return true
        }
        else {
            return false
        }
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            locationsSelected.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
