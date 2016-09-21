//
//  ClientTableViewController.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/22/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit

class ClientTableViewController: UITableViewController {

    @IBOutlet weak var clientTableView: UITableView!
    var classDate = ClassDate()
    var fullClientList = ClientCollection()
    var sortedClientList = [Client]()

    override func viewDidLoad() {
        //Set header
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "E, MMM d, yyyy"
        self.navigationItem.title = dateFormatter.stringFromDate(classDate.date) + " - " + String(classDate.checkIns.count);

        //Sort clients
        for checkIn in classDate.checkIns {
            if let client = fullClientList[checkIn.clientReference!.recordID] {
                sortedClientList.append(client)
            }
        }

        sortedClientList.sortInPlace { $0.name.compare($1.name) == .OrderedAscending }

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //TODO: Don't load events here, find a way to just load new ones.
    override func viewDidAppear(animated: Bool) {
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedClientList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell : SimpleLabelTableViewCell
        cell = tableView.dequeueReusableCellWithIdentifier("ClientCell") as! SimpleLabelTableViewCell

        //TODO add errors
        let client = sortedClientList[indexPath.row]

        cell.label.text = client.name

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ClientClicked", sender: self);
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "ClientClicked") {
            let controller = (segue.destinationViewController as! ClientViewController)
            let row = self.clientTableView.indexPathForSelectedRow!.row
            let client = sortedClientList[row]
            controller.client = client
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

