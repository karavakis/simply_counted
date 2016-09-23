//
//  ClassTableViewController.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/21/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//
import UIKit

class ClassTableViewController: UITableViewController {

    @IBOutlet weak var classTableView: UITableView!
    var classes = ClassCollection()
    var fullClientList = ClientCollection()
    var isLoading = false
    

    func classesDidLoad() -> Void {
        isLoading = false
        classTableView.reloadData()
    }

    override func viewDidLoad() {
        self.navigationItem.title = "Class Dates";
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        isLoading = true

        classes.load(classesDidLoad)
    }

    //TODO: Don't load events here, find a way to just load new ones.
    override func viewDidAppear(animated: Bool) {
        if( !isLoading ) {
            isLoading = true
            classes.load(classesDidLoad)
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isLoading {
            return 0
        }
        else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell : SimpleLabelTableViewCell
        cell = tableView.dequeueReusableCellWithIdentifier("ClassCell") as! SimpleLabelTableViewCell

        //TODO add errors
        if let classDate = classes[indexPath.row] {

            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
            cell.label.text = dateFormatter.stringFromDate(classDate.date)

            cell.label2.text = String(classDate.checkIns.count)
        }


        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "classClicked") {
            let controller = (segue.destinationViewController as! ClientTableViewController)
            let row = self.classTableView.indexPathForSelectedRow!.row
            let classDate = classes[row]
            if let classDate = classDate {
                controller.classDate = classDate
                controller.fullClientList = fullClientList
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

