//
//  AddPassViewController.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 9/2/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import LocalAuthentication

class AddPassViewController: UIViewController, UITableViewDelegate {

    var client : Client? = nil
    var passTypes = PassTypeCollection()
    @IBOutlet weak var passTypeTableView: UITableView!
    var isLoading = false
    var passAddedHandler:(()->Void)!

    func passTypesDidLoad() -> Void {
        isLoading = false
        passTypeTableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        isLoading = true
        passTypes.load(passTypesDidLoad)

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*******************/
    /* Load Table View */
    /*******************/
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isLoading {
            return 1
        }
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return 1
        }
        else {
            return passTypes.count()
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var returnCell : UITableViewCell

        if(indexPath.section == 0) {
            var cell : AddPassTypeTableViewCell
            cell = tableView.dequeueReusableCellWithIdentifier("AddPassTypeCell") as! AddPassTypeTableViewCell

            func completionHandler(passType: PassType) -> Void {
                passTypes.add(passType)
                self.passTypeTableView.reloadData()
            }

            cell.completionHandler = completionHandler

            returnCell = cell
        }
        else {
            var cell : SimpleLabelTableViewCell
            cell = tableView.dequeueReusableCellWithIdentifier("PassTypeCell") as! SimpleLabelTableViewCell
            if let passType = passTypes[indexPath.row] {
                cell.label.text = String(passType.passCount) + " Pass"
                cell.label2.text = "$" + String(passType.price)
            }
            returnCell = cell
        }

        return returnCell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section > 0) {
            self.dismissViewControllerAnimated(true, completion: nil)
            if let passType = passTypes[indexPath.row] {
                if let client = client {
                    client.addPasses(passType)
                    if self.passAddedHandler != nil {
                        self.passAddedHandler()
                    }
                }
            }
        }
        else {
            tableView.cellForRowAtIndexPath(indexPath)?.selected = false
        }
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {

            func deleteSuccess() {
                passTypes.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }

            func errorHandler(error: NSError) {
                print("Error: \(error) \(error.userInfo)")
            }

            passTypes[indexPath.row]?.deleteRecord(deleteSuccess, errorHandler: errorHandler)
        }
    }

}
