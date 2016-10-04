//
//  NotesViewController.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/30/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var numPassesLeftLabel: UILabel!
    @IBOutlet weak var numTotalCheckInsLabel: UILabel!
    @IBOutlet weak var numTotalPassesLabel: UILabel!
    @IBOutlet weak var priceTotalAmountPaidLabel: UILabel!
    @IBOutlet weak var checkInDatePicker: UIDatePicker!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var activitiesTableView: UITableView!
    @IBOutlet weak var addPassButton: UIButton!
    @IBOutlet weak var notesTextField: UITextView!

    var client:Client? = nil //passed in from last view

    func reloadActivitiesTable() -> Void {
        activitiesTableView.reloadData()
        populateClientInfo()
    }

    override func viewDidLoad() {

        setupBarButtonItems()
        if let client = self.client {
            //Set header
            self.navigationItem.title = client.name
            reloadActivitiesTable()
        }
        super.viewDidLoad()
        setupDatePicker()
        notesTextField.text = client!.notes
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
            numPassesLeftLabel.text = String(client.passes)
            numTotalCheckInsLabel.text = String(client.totalCheckIns)
            numTotalPassesLabel.text = String(client.totalPasses)
            priceTotalAmountPaidLabel.text = "$" + String(describing: client.totalPrice)
        }
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


            // Price and Pass Count
            var price = ""
            var passText = ""
            if let passActivity = client.activities[indexPath.row] as? PassActivity {
                cell = tableView.dequeueReusableCell(withIdentifier: "PassCell") as! SimpleLabelTableViewCell
                passText = String(passActivity.passesAdded)
                price = "$" + passActivity.price

                cell.label3.text = price
                cell.label2.text = passText
            }

            //Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, MMM d, yyyy"
            let dateText = dateFormatter.string(from: client.activities[indexPath.row].date)
            cell.label.text = dateText
        }

        return cell
    }

    internal func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    /************/
    /* Check-In */
    /************/
    @IBAction func checkInClicked(_ sender: AnyObject) {
        if let client = client {
            if (client.passes <= 0) {
                let noPassesAlert = UIAlertController(title: "Error", message: "Please load passes before checking in.", preferredStyle: UIAlertControllerStyle.alert)
                noPassesAlert.addAction(UIAlertAction(title: "Unlock", style: .default, handler: { (action: UIAlertAction!) in
                    unlockUser(self.checkIn)
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

    /********/
    /* Save */
    /********/
    func setupBarButtonItems() {
        let notesButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(NotesViewController.saveClicked))
        self.navigationItem.rightBarButtonItem = notesButton
    }

    func saveClicked() {
        client!.notes = notesTextField.text
        client!.save(nil)
        _ = navigationController?.popViewController(animated: true)
    }

    /**********/
    /* Segues */
    /**********/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "AddPassClicked") {
            let popoverViewController = segue.destination as! AddPassViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverViewController.popoverPresentationController!.delegate = self
            popoverViewController.client = client
            popoverViewController.passAddedHandler = passAddedHandler
            fixIOS9PopOverAnchor(segue)
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        return .none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
