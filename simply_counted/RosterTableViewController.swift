//
//  RosterTableViewController.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/19/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import Parse

class RosterTableViewController: UITableViewController {

    @IBOutlet weak var RosterTableView: UITableView!
    var clients = ClientCollection()
    var clientsIndexedList = [String:[Client]]()
    var clientIndexes = [String]()
    var isLoading = false

    func clientsDidLoad() -> Void {
        isLoading = false
        clientsIndexedList = clients.getIndexedList()
        clientIndexes = Array(clientsIndexedList.keys).sort(<)
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        isLoading = true
        clients.load(clientsDidLoad)

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        RosterTableView.reloadData()
    }

    /*******************/
    /* Load Table View */
    /*******************/
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isLoading {
            return 1
        }
        return clientsIndexedList.count + 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return 1
        }
        else {
            return clientsIndexedList[clientIndexes[section-1]]!.count
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0){
            return ""
        }
        else {
            return clientIndexes[section-1]
        }
    }
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return clientIndexes
    }

    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if let index = clientIndexes.indexOf(title) {
            return index + 1
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var returnCell : UITableViewCell

        if ( indexPath.section != 0 ) {

            var cell : ClientTableViewCell
            cell = tableView.dequeueReusableCellWithIdentifier("ClientCell") as! ClientTableViewCell

            //TODO add errors
            let client = clientsIndexedList[clientIndexes[indexPath.section-1]]![indexPath.row]

            cell.checkmarkImage.hidden = true
            cell.nameLabel.text = client.name


            //Date
            if let lastCheckIn = client.lastCheckIn {
                if(NSCalendar.currentCalendar().isDate(lastCheckIn, inSameDayAsDate: NSDate())) {
                    cell.checkmarkImage.hidden = false
                    cell.lastCheckInLabel.text = "Today"
                }
                else {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "M/d/y"
                    cell.lastCheckInLabel.text = dateFormatter.stringFromDate(lastCheckIn)
                }
            }
            else {
                cell.lastCheckInLabel.text = ""
            }

            returnCell = cell
        }
        else {
            var cell : AddClientTableViewCell
            cell = tableView.dequeueReusableCellWithIdentifier("AddClientCell") as! AddClientTableViewCell

            func completionHandler(client: Client) -> Void {
                isLoading = true
                clients.append(client)
                clientsDidLoad()
            }

            cell.completionHandler = completionHandler

            returnCell = cell
        }

        return returnCell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section > 0) {
            self.performSegueWithIdentifier("ClientClicked", sender: self)
        }
        else {
            tableView.cellForRowAtIndexPath(indexPath)?.selected = false
        }
    }

    /**********/
    /* Segues */
    /**********/
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "ClientClicked") {
            let controller = (segue.destinationViewController as! ClientViewController)
            let section = self.RosterTableView.indexPathForSelectedRow!.section
            let row = self.RosterTableView.indexPathForSelectedRow!.row
            let client = clientsIndexedList[clientIndexes[section-1]]![row]
            controller.client = client
        }
        if (segue.identifier == "ClassListClicked") {
            let tabBarController = (segue.destinationViewController as! UITabBarController)
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

