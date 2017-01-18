//
//  ClientViewController.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/19/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit

class ClientViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var numPassesLeftLabel: UILabel!
    @IBOutlet weak var numTotalCheckInsLabel: UILabel!
    @IBOutlet weak var numTotalPassesLabel: UILabel!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var activitiesTableView: UITableView!

    var client : Client? = nil

    func reloadActivitiesTable() -> Void {
        activitiesTableView.reloadData()
        populateClientInfo()
    }

    override func viewDidLoad() {
        setupBarButtonItems()
        if let client = self.client {
            //Set header
            self.navigationItem.title = client.name
            populateClientInfo()
            client.loadActivities(reloadActivitiesTable)
        }
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        populateClientInfo()
        reloadActivitiesTable() 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /************************/
    /* Populate Client Info */
    /************************/
    func populateClientInfo() {
        if let client : Client = client {
            numPassesLeftLabel.text = String(client.passes)
            numTotalCheckInsLabel.text = String(client.totalCheckIns)
            numTotalPassesLabel.text = String(client.totalPasses)
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

    /***************/
    /* Edit Client */
    /***************/
    func setupBarButtonItems() {
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(ClientViewController.editClicked))
        self.navigationItem.rightBarButtonItem = editButton
    }

    func editClicked() {
        func goToEditPage() {
            performSegue(withIdentifier: "EditClicked", sender: nil)
        }
        unlockUser(goToEditPage)
    }

    /************/
    /* Check-In */
    /************/
    @IBAction func checkInClicked(_ sender: AnyObject) {
        if let client = client {
            if (client.passes <= 0) {
                let noPassesAlert = UIAlertController(title: "!", message: "No passes remaining.\n\nPlease click edit to unlock check-in with no passes.", preferredStyle: UIAlertControllerStyle.alert)
                noPassesAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                }))
                present(noPassesAlert, animated: true, completion: nil)
            }
            else {
                self.checkIn()
            }
        }
    }

    func checkIn() {
        client!.checkIn(Date())
        _ = navigationController?.popViewController(animated: true)
    }

    /**********/
    /* Segues */
    /**********/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "EditClicked") {
            if let client = client {
                let controller = (segue.destination as! EditClientViewController)
                controller.client = client
            }
        }
    }

    
}

