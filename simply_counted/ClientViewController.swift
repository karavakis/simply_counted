//
//  ClientViewController.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/19/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import LocalAuthentication

class ClientViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {

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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
        let today = Date()
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

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }


    /*********************/
    /* Authenticate User */
    /*********************/
    func unlockUser(_ unlockSuccess: @escaping () -> Void) {
        let context = LAContext()

        if (LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)) {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: "Please authenticate to proceed.") { (success, error) in

                guard success else {
                    DispatchQueue.main.async {
                        // show something here to block the user from continuing
                    }

                    return
                }

                DispatchQueue.main.async {
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let client : Client = client {
            return client.activities.count
        }
        return 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : SimpleLabelTableViewCell
        cell = tableView.dequeueReusableCell(withIdentifier: "CheckInCell") as! SimpleLabelTableViewCell

        if let client : Client = client {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.full
            dateFormatter.timeStyle = DateFormatter.Style.none
            let dateText = dateFormatter.string(from: client.activities[indexPath.row].date)
            var passText = ""
            if let passActivity = client.activities[indexPath.row] as? PassActivity {
                passText = String(passActivity.passesAdded) + " Pass"
            }
            cell.label.text = dateText
            cell.label2.text = passText
        }

        return cell
    }

    internal func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }


    /*********/
    /* Notes */
    /*********/
    func setupBarButtonItems() {
        let notesButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(ClientViewController.notesClicked))
        self.navigationItem.rightBarButtonItem = notesButton
    }

    func notesClicked() {
        performSegue(withIdentifier: "NotesClicked", sender: nil)
    }

    /************/
    /* Check-In */
    /************/
    @IBAction func checkInClicked(_ sender: AnyObject) {
        if let client = client {
            if (client.passes <= 0) {
                let noPassesAlert = UIAlertController(title: "Error", message: "Please load passes before checking in.", preferredStyle: UIAlertControllerStyle.alert)
                noPassesAlert.addAction(UIAlertAction(title: "Unlock", style: .default, handler: { (action: UIAlertAction!) in
                    self.unlockUser(self.checkIn)
                }))
                noPassesAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
                }))
                present(noPassesAlert, animated: true, completion: nil)
            }
            else {
                self.checkIn()
            }
        }
    }

    func checkIn() {
        client!.checkIn(checkInDatePicker.date)
        _ = navigationController?.popViewController(animated: true)
    }

    /************/
    /* Add Pass */
    /************/
    @IBAction func addPassClicked(_ sender: AnyObject) {
        func addPass() {
            performSegue(withIdentifier: "AddPassClicked", sender: self)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "NotesClicked") {
            if let client = client {
                let controller = (segue.destination as! NotesViewController)
                controller.client = client
            }
        }
        if (segue.identifier == "AddPassClicked") {
            let popoverViewController = segue.destination as! AddPassViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverViewController.popoverPresentationController!.delegate = self
            popoverViewController.client = client
            popoverViewController.passAddedHandler = passAddedHandler
            fixIOS9PopOverAnchor(segue)
        }
    }

    
}

