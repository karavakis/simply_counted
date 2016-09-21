//
//  ClientViewController.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/19/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import LocalAuthentication

class ClientViewController: UIViewController, UITableViewDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var passesLabel: UILabel!
    @IBOutlet weak var checkInDatePicker: UIDatePicker!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var activitiesTableView: UITableView!

    // Hideable
    @IBOutlet weak var addPassButton: UIButton!
    @IBOutlet weak var addClassPassButton: UIButton!
    @IBOutlet weak var removeClassPathButton: UIButton!
    @IBOutlet weak var addClassPassesButtons: UISegmentedControl!

    var client : Client? = nil
    var allowNegative = false
    var ifAddClicked = true

    func reloadActivitiesTable() -> Void {
        activitiesTableView.reloadData()
    }

    override func viewDidLoad() {

        setupBarButtonItems()
        if let client = self.client {
            //Set header
            self.navigationItem.title = client.name

            client.loadActivities(reloadActivitiesTable)
        }
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        populateClientInfo()
        setupDatePicker()
//        setupPickerView()
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*********************/
    /* Setup Date Picker */
    /*********************/
    func setupDatePicker() {
        let today = NSDate()
        checkInDatePicker.setDate(today, animated: true)
        checkInDatePicker.maximumDate = today
    }

    /************************/
    /* Populate Client Info */
    /************************/
    func populateClientInfo() {
        if let client : Client = client {
            passesLabel.text = "Passes Remaining: " + String(client.passes)
        }
    }

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }


    /*********************/
    /* Authenticate User */
    /*********************/
    func unlockUser(unlockSuccess: () -> Void) {
        let context = LAContext()

        if (LAContext().canEvaluatePolicy(.DeviceOwnerAuthentication, error: nil)) {
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthentication, localizedReason: "Please authenticate to proceed.") { (success, error) in

                guard success else {
                    dispatch_async(dispatch_get_main_queue()) {
                        // show something here to block the user from continuing
                    }

                    return
                }

                dispatch_async(dispatch_get_main_queue()) {
                    // do something here to continue loading your app, e.g. call a delegate method
                    unlockSuccess()
                }
            }
        }
        else {
            //Passcode not set
            unlockSuccess()
        }
        return
    }

    /*******************/
    /* Load Table View */
    /*******************/
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let client : Client = client {
            return client.activities.count
        }
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> SimpleLabelTableViewCell {
        var cell : SimpleLabelTableViewCell
        cell = tableView.dequeueReusableCellWithIdentifier("CheckInCell") as! SimpleLabelTableViewCell

        if let client : Client = client {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
            let dateText = dateFormatter.stringFromDate(client.activities[indexPath.row].date)
            var passText = ""
            if let passActivity = client.activities[indexPath.row] as? PassActivity {
                passText = String(passActivity.passesAdded) + " Pass"
            }
            cell.label.text = dateText
            cell.label2.text = passText
        }

        return cell
    }

    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }


    /*********/
    /* Notes */
    /*********/
    func setupBarButtonItems() {
        let notesButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: #selector(ClientViewController.notesClicked))
        self.navigationItem.rightBarButtonItem = notesButton
    }

    func notesClicked() {
        performSegueWithIdentifier("NotesClicked", sender: nil)
    }

    /************/
    /* Check-In */
    /************/
    @IBAction func checkInClicked(sender: AnyObject) {
        if let client = client {
            if (client.passes <= 0) {
                let noPassesAlert = UIAlertController(title: "Error", message: "Please load passes before checking in.", preferredStyle: UIAlertControllerStyle.Alert)
                noPassesAlert.addAction(UIAlertAction(title: "Unlock", style: .Default, handler: { (action: UIAlertAction!) in
                    self.unlockUser(self.checkIn)
                }))
                noPassesAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                }))
                presentViewController(noPassesAlert, animated: true, completion: nil)
            }
            else {
                self.checkIn()
            }
        }
    }

    func checkIn() {
        client!.checkIn(checkInDatePicker.date)
        navigationController?.popViewControllerAnimated(true)
    }

    /************/
    /* Add Pass */
    /************/
    @IBAction func addPassClicked(sender: AnyObject) {
        func addPass() {
            performSegueWithIdentifier("AddPassClicked", sender: self)
        }
        unlockUser(addPass)
    }

    func passAddedHandler() {
        reloadActivitiesTable()
        populateClientInfo()
    }

    /**********/
    /* Segues */
    /**********/
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "NotesClicked") {
            if let client = client {
                let controller = (segue.destinationViewController as! NotesViewController)
                controller.client = client
            }
        }
        if (segue.identifier == "AddPassClicked") {
            let popoverViewController = segue.destinationViewController as! AddPassViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
            popoverViewController.client = client
            popoverViewController.passAddedHandler = passAddedHandler
            fixIOS9PopOverAnchor(segue)
        }
    }

    
}

