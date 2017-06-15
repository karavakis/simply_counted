////
////  ClientViewController.swift
////  simply_counted
////
////  Created by Jennifer Karavakis on 8/19/16.
////  Copyright © 2017 Jennifer Karavakis. All rights reserved.
////
//
//import UIKit
//import LocalAuthentication
//
//class ClientViewController: UIViewController, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
//UIPickerViewDataSource, UIPickerViewDelegate {
//    @IBOutlet weak var clientNameLabel: UILabel!
//    @IBOutlet weak var passesLabel: UILabel!
//    @IBOutlet weak var checkInDatePicker: UIDatePicker!
//    @IBOutlet weak var checkInButton: UIButton!
//    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var passTextField: UITextField!
//
//    // Hideable
//    @IBOutlet weak var unlockMoreOptionsLabel: UIButton!
//    @IBOutlet weak var addClassPassButton: UIButton!
//    @IBOutlet weak var removeClassPathButton: UIButton!
//    @IBOutlet weak var addClassPassesButtons: UISegmentedControl!
//    @IBOutlet weak var deleteUserButton: UIButton!
//
//    var client : Client? = nil
//    var allowNegative = false
//    var ifAddClicked = true
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//        toggleMoreOptions()
//        populateClientInfo()
//        setupDatePicker()
//        setupPickerView()
//    }
//
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        self.view.endEditing(true)
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//    /*********************/
//    /* Setup Date Picker */
//    /*********************/
//    func setupDatePicker() {
//        let today = NSDate()
//        checkInDatePicker.setDate(today, animated: true)
//        checkInDatePicker.maximumDate = today
//    }
//
//    /************************/
//    /* Populate Client Info */
//    /************************/
//    func populateClientInfo() {
//        if let client : Client = client {
//            clientNameLabel.text = client.name
//            passesLabel.text = "Passes Remaining: " + String(client.passes)
//        }
//    }
//
//    /*********************/
//    /* Update Class Pass */
//    /*********************/
//    func setupPickerView() {
//        let pickerView = UIPickerView()
//        pickerView.delegate = self
//        passTextField.inputView = pickerView
//
//        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
//        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(ClientViewController.donePressed))
//        let pickerToolbar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
//        pickerToolbar.setItems([flexSpace, doneButton], animated: true)
//        passTextField.inputAccessoryView = pickerToolbar
//
//        passTextField.text = "1"
//    }
//
//    func donePressed() {
//        passTextField.resignFirstResponder()
//        if let passes = passTextField.text {
//            if let passNumber = Int(passes) {
//                addPassActivity(passNumber)
//            }
//        }
//    }
//
//    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return 99
//    }
//
//    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return String(row + 1)
//    }
//
//    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        passTextField.text = String(row + 1)
//    }
//
//    func addPassActivity(passes : Int) {
//        if let client = self.client {
//            let changedPasses = ifAddClicked ? passes : passes * -1
//            client.addPasses(changedPasses)
//            populateClientInfo()
//
//            let addString = "The " + String(changedPasses) + " class pass was added successfully."
//            let wasWere = changedPasses == -1 ? " was" : "es were"
//            let removeString =  String(changedPasses * -1) + " class pass" + wasWere + " removed successfully."
//            let message = ifAddClicked ? addString : removeString
//
//
//            let passAddedAlert = UIAlertController(title: "Pass Added", message: message, preferredStyle: UIAlertControllerStyle.Alert)
//            passAddedAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
//            }))
//
//            presentViewController(passAddedAlert, animated: true, completion: nil)
//        }
//    }
//
//    func updateClassPath() {
//        var changedPasses = 0
//        switch addClassPassesButtons.selectedSegmentIndex {
//        case 0:
//            changedPasses = 1
//        case 1:
//            changedPasses = 12
//        case 2:
//            changedPasses = 20
//        case 3:
//            changedPasses = 30
//        default:
//            changedPasses = 0
//            break;
//        }
//        if(changedPasses == 0) {
//            passTextField.becomeFirstResponder()
//        }
//        else {
//            addPassActivity(changedPasses)
//        }
//    }
//
//    @IBAction func addClassPass(sender: AnyObject) {
//        ifAddClicked = true
//        updateClassPath()
//    }
//
//    @IBAction func removeClassPath(sender: AnyObject) {
//        ifAddClicked = false
//        updateClassPath()
//    }
//
//
//    /*********************/
//    /* Authenticate User */
//    /*********************/
//
//    @IBAction func unlockOptions(sender: AnyObject) {
//        let context = LAContext()
//
//        context.evaluatePolicy(LAPolicy.DeviceOwnerAuthentication, localizedReason: "Please authenticate to proceed.") { [weak self] (success, error) in
//
//            guard success else {
//                dispatch_async(dispatch_get_main_queue()) {
//                    // show something here to block the user from continuing
//                }
//
//                return
//            }
//
//            dispatch_async(dispatch_get_main_queue()) {
//                // do something here to continue loading your app, e.g. call a delegate method
//                self!.toggleMoreOptions()
//            }
//        }
//    }
//
//    func toggleMoreOptions() {
//        addClassPassButton.hidden = !addClassPassButton.hidden
//        removeClassPathButton.hidden = !removeClassPathButton.hidden
//        addClassPassesButtons.hidden = !addClassPassesButtons.hidden
//        unlockMoreOptionsLabel.hidden = !addClassPassesButtons.hidden
//        deleteUserButton.hidden = !unlockMoreOptionsLabel.hidden
//        allowNegative = !addClassPassesButtons.hidden
//    }
//
//
//    /*******************/
//    /* Load Table View */
//    /*******************/
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let client : Client = client {
//            return client.activities.count
//        }
//        return 0
//    }
//
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> SimpleLabelTableViewCell {
//        var cell : SimpleLabelTableViewCell
//        cell = tableView.dequeueReusableCellWithIdentifier("CheckInCell") as! SimpleLabelTableViewCell
//
//        if let client : Client = client {
//            let dateFormatter = NSDateFormatter()
//            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
//            dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
//            cell.label.text = dateFormatter.stringFromDate(client.activities[indexPath.row].date)
//        }
//
//        return cell
//    }
//
//    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
//        return true
//    }
//
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if (segue.identifier == "CheckInClicked") {
//            if let client = client {
//                if (client.passes <= 0 && !allowNegative) {
//                    let noPassesAlert = UIAlertController(title: "Error", message: "Please load passes before checking in.", preferredStyle: UIAlertControllerStyle.Alert)
//                    noPassesAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
//                    }))
//
//                    presentViewController(noPassesAlert, animated: true, completion: nil)
//                }
//                else {
//                    client.checkIn(checkInDatePicker.date)
//                }
//            }
//        }
//        if (segue.identifier == "DeleteClicked") {
//            if let client = client {
//                let deleteAlert = UIAlertController(title: "Warning", message: "You are about to delete this user. This action cannot be undone.", preferredStyle: UIAlertControllerStyle.Alert)
//                deleteAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
//                    func deleteSuccess() {
//                        segue.perform()
//                    }
//                    client.deleteClient(deleteSuccess)
//                }))
//                deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
//                    //Do nothing
//                }))
//                
//                presentViewController(deleteAlert, animated: true, completion: nil)
//            }
//        }
//    }
//}
//
