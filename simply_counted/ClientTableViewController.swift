//
//  ClientTableViewController.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/22/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import Parse

class ClientTableViewController: UITableViewController {

    @IBOutlet weak var clientTableView: UITableView!
    var classDate = ClassDate()
    var fullClientList = ClientCollection()


    override func viewDidLoad() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "E, MMM d, yyyy"
        self.navigationItem.title = dateFormatter.stringFromDate(classDate.date);
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
        return classDate.checkIns.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell : SimpleLabelTableViewCell
        cell = tableView.dequeueReusableCellWithIdentifier("ClientCell") as! SimpleLabelTableViewCell

        //TODO add errors
        if let client = fullClientList[classDate.checkIns[indexPath.row].clientId] {

            cell.label.text = client.name
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ClientClicked", sender: self);
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "ClientClicked") {
            let controller = (segue.destinationViewController as! ClientViewController)
            let row = self.clientTableView.indexPathForSelectedRow!.row
            let client = fullClientList[classDate.checkIns[row].clientId]
            controller.client = client
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

