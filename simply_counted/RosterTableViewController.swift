//
//  RosterTableViewController.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/19/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit

class RosterTableViewController: UITableViewController {

    @IBOutlet weak var RosterTableView: UITableView!
    var clients = ClientCollection()
    var clientsIndexedList = [String:[Client]]()
    var clientIndexes = [String]()
    var isLoading = false

    func clientsDidLoad() -> Void {
        isLoading = false
        clientsIndexedList = clients.getIndexedList()
        clientIndexes = Array(clientsIndexedList.keys).sorted(by: <)
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        isLoading = true
        clients.load(clientsDidLoad)

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        RosterTableView.reloadData()
    }

    /*******************/
    /* Load Table View */
    /*******************/
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isLoading {
            return 1
        }
        return clientsIndexedList.count + 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return 1
        }
        else {
            return clientsIndexedList[clientIndexes[section-1]]!.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0){
            return ""
        }
        else {
            return clientIndexes[section-1]
        }
    }
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return clientIndexes
    }

    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if let index = clientIndexes.index(of: title) {
            return index + 1
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var returnCell : UITableViewCell

        if ( indexPath.section != 0 ) {

            var cell : ClientTableViewCell
            cell = tableView.dequeueReusableCell(withIdentifier: "ClientCell") as! ClientTableViewCell

            //TODO add errors
            let client = clientsIndexedList[clientIndexes[indexPath.section-1]]![indexPath.row]

            cell.checkmarkImage.isHidden = true
            cell.nameLabel.text = client.name


            //Date
            if let lastCheckIn = client.lastCheckIn {
                if(Calendar.current.isDate(lastCheckIn as Date, inSameDayAs: Date())) {
                    cell.checkmarkImage.isHidden = false
                    cell.lastCheckInLabel.text = "Today"
                }
                else {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "M/d/y"
                    cell.lastCheckInLabel.text = dateFormatter.string(from: lastCheckIn as Date)
                }
            }
            else {
                cell.lastCheckInLabel.text = ""
            }

            returnCell = cell
        }
        else {
            var cell : AddClientTableViewCell
            cell = tableView.dequeueReusableCell(withIdentifier: "AddClientCell") as! AddClientTableViewCell

            func completionHandler(_ client: Client) -> Void {
                isLoading = true
                clients.append(client)
                clientsDidLoad()
            }

            cell.completionHandler = completionHandler

            returnCell = cell
        }

        return returnCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section > 0) {
            self.performSegue(withIdentifier: "ClientClicked", sender: self)
        }
        else {
            tableView.cellForRow(at: indexPath)?.isSelected = false
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {

            func deleteClient() {
                func deleteSuccess() {
                    clientsIndexedList[clientIndexes[indexPath.section-1]]?.remove(at: indexPath.row)
                    if(clientsIndexedList[clientIndexes[indexPath.section-1]]?.count == 0) {
                        clientsIndexedList.removeValue(forKey: clientIndexes[indexPath.section-1])
                        clientIndexes.remove(at: indexPath.section-1)
                        var indexSet = IndexSet()
                        indexSet.insert(indexPath.section)
                        tableView.deleteSections(indexSet, with: UITableViewRowAnimation.automatic)
                    }
                    else {
                        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    }
                }

                func errorHandler(_ error: NSError) {
                    print("Error: \(error) \(error.userInfo)")
                }

                clientsIndexedList[clientIndexes[indexPath.section-1]]?[indexPath.row].deleteRecord(deleteSuccess, errorHandler: errorHandler)
            }

            let deleteClientWarning = UIAlertController(title: "Warning", message: "Deleting a client will delete all Check-Ins and Passes associated with the client.", preferredStyle: UIAlertControllerStyle.alert)
            deleteClientWarning.addAction(UIAlertAction(title: "Keep", style: .default, handler: { (action: UIAlertAction!) in
                tableView.setEditing(false, animated: true)
            }))
            deleteClientWarning.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action: UIAlertAction!) in
                unlockUser(deleteClient)
            }))
            present(deleteClientWarning, animated: true, completion: nil)
        }
    }

    /**********/
    /* Segues */
    /**********/
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "ClientClicked") {
            let controller = (segue.destination as! ClientViewController)
            let section = self.RosterTableView.indexPathForSelectedRow!.section
            let row = self.RosterTableView.indexPathForSelectedRow!.row
            let client = clientsIndexedList[clientIndexes[section-1]]![row]
            controller.client = client
        }
        if (segue.identifier == "ClassListClicked") {
            let tabBarController = (segue.destination as! UITabBarController)
            let classTableVC = tabBarController.viewControllers?[0] as! ClassTableViewController
            let passTableVC = tabBarController.viewControllers?[1] as! PassTableViewController

            classTableVC.fullClientList = clients
            passTableVC.fullClientList = clients
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

