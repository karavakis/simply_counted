//
//  ClientViewController.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/19/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import LocalAuthentication

class ClientViewController: UIViewController, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var clientNameLabel: UILabel!
    @IBOutlet weak var passesLabel: UILabel!
    @IBOutlet weak var checkInDatePicker: UIDatePicker!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    // Hideable
    @IBOutlet weak var unlockMoreOptionsLabel: UIButton!
    @IBOutlet weak var addClassPassButton: UIButton!
    @IBOutlet weak var removeClassPathButton: UIButton!
    @IBOutlet weak var addClassPassesButtons: UISegmentedControl!
    @IBOutlet weak var deleteUserButton: UIButton!

    var client : Client? = nil

    var allowNegative = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        toggleMoreOptions()
        populateClientInfo()
        setupDatePicker()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*************/
    /* Set image */
    /*************/
    @IBAction func imageClicked(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
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
            clientNameLabel.text = client.name
            passesLabel.text = "Passes Remaining: " + String(client.passes)
        }
    }

    /*********************/
    /* Update Class Pass */
    /*********************/
    func updateClassPath(add: Bool) {
        if let client = self.client {
            var changedPasses = 0
            switch addClassPassesButtons.selectedSegmentIndex {
            case 0:
                changedPasses = 1
            case 1:
                changedPasses = 12
            case 2:
                changedPasses = 20
            case 3:
                changedPasses = 30
            default:
                break;
            }
            changedPasses = add ? changedPasses : changedPasses * -1
            client.passes += changedPasses
            client.update()
            populateClientInfo()

            let addString = "The " + String(changedPasses) + " class pass was added successfully."
            let wasWere = changedPasses == -1 ? " was" : "es were"
            let removeString =  String(changedPasses * -1) + " class pass" + wasWere + " removed successfully."
            let message = add ? addString : removeString


            let passAddedAlert = UIAlertController(title: "Pass Added", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            passAddedAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            }))

            presentViewController(passAddedAlert, animated: true, completion: nil)
        }

    }

    @IBAction func addClassPass(sender: AnyObject) {
        updateClassPath(true)
    }

    @IBAction func removeClassPath(sender: AnyObject) {
        updateClassPath(false)
    }


    /*********************/
    /* Authenticate User */
    /*********************/

    @IBAction func unlockOptions(sender: AnyObject) {
        let context = LAContext()

        context.evaluatePolicy(LAPolicy.DeviceOwnerAuthentication, localizedReason: "Please authenticate to proceed.") { [weak self] (success, error) in

            guard success else {
                dispatch_async(dispatch_get_main_queue()) {
                    // show something here to block the user from continuing
                }

                return
            }

            dispatch_async(dispatch_get_main_queue()) {
                // do something here to continue loading your app, e.g. call a delegate method
                self!.toggleMoreOptions()
            }
        }
    }

    func toggleMoreOptions() {
        addClassPassButton.hidden = !addClassPassButton.hidden
        removeClassPathButton.hidden = !removeClassPathButton.hidden
        addClassPassesButtons.hidden = !addClassPassesButtons.hidden
        unlockMoreOptionsLabel.hidden = !addClassPassesButtons.hidden
        deleteUserButton.hidden = !unlockMoreOptionsLabel.hidden
        allowNegative = !addClassPassesButtons.hidden
    }


    /*******************/
    /* Load Table View */
    /*******************/
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let client : Client = client {
            return client.checkIns.count
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
            cell.label.text = dateFormatter.stringFromDate(client.checkIns[indexPath.row].date)
        }

        return cell
    }

    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "CheckInClicked") {
            if let client = client {
                if (client.passes <= 0 && !allowNegative) {
                    let noPassesAlert = UIAlertController(title: "Error", message: "Please load passes before checking in.", preferredStyle: UIAlertControllerStyle.Alert)
                    noPassesAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                    }))

                    presentViewController(noPassesAlert, animated: true, completion: nil)
                }
                else {
                    client.checkIn(checkInDatePicker.date)
                }
            }
        }
        if (segue.identifier == "DeleteClicked") {
            if let client = client {
                let deleteAlert = UIAlertController(title: "Warning", message: "You are about to delete this user. This action cannot be undone.", preferredStyle: UIAlertControllerStyle.Alert)
                deleteAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                    func deleteSuccess() {
                        segue.perform()
                    }
                    client.deleteClient(deleteSuccess)
                }))
                deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                    //Do nothing
                }))

                presentViewController(deleteAlert, animated: true, completion: nil)
            }
        }
    }
}

