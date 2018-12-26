//
//  ClientViewController.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/19/16.
//  Copyright © 2017 Jennifer Karavakis. All rights reserved.
//

import UIKit

class ClientViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var numPassesLeftLabel: UILabel!
    @IBOutlet weak var numTotalCheckInsLabel: UILabel!
    @IBOutlet weak var numTotalPassesLabel: UILabel!
    @IBOutlet weak var moreOptionsButton: UIButton!
    @IBOutlet weak var activitiesTableView: UITableView!

    @objc var checkInButton: UIBarButtonItem!
    var client : Client? = nil
    var successfulLogin: Bool = false
    let touchAuth = TouchIDAuth()
    
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
        self.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
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

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Activities"
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
                let passesString = passActivity.passesAdded == 1 ? " Pass" : " Passes"
                passText = String(passActivity.passesAdded) + passesString
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
    
    func dismissed(_ successfulLogin: Bool) {
        self.successfulLogin = successfulLogin
    }

    /***************/
    /* Edit Client */
    /***************/
    @IBAction func moreOptionsClicked(_ sender: AnyObject) {
        
        let useTouchId = TouchIDAuth().useTouchId as Bool?
        
        if (useTouchId == nil) {
            let alertController = UIAlertController(title: "Use TouchID?", message: "Would you like to use TouchID to authenticate modifying clients?", preferredStyle: .actionSheet)
        
            let confirmAction = UIAlertAction(title: "Yes", style: .default) { (_) in
                UserDefaults.standard.set(true, forKey: "use_touchid")
                self.authenticateUser()
            }
        
            let cancelAction = UIAlertAction(title: "No", style: .cancel) { (_) in
                UserDefaults.standard.set(false, forKey: "use_touchid")
                self.performSegue(withIdentifier: "EditClient", sender: nil)
            }
        
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
        
            self.present(alertController, animated: true, completion: nil)
        } else {
            if(useTouchId == true) {
                authenticateUser()
            }
            else {
                self.performSegue(withIdentifier: "EditClient", sender: nil)
            }
        }
    }

    func authenticateUser() {
        touchAuth.authenticateUser() { message in
            
            if let message = message {
                let alertView = UIAlertController(title: "Error",
                                                  message: message,
                                                  preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                alertView.addAction(okAction)
                self.present(alertView, animated: true)
                
            } else {
                self.performSegue(withIdentifier: "EditClient", sender: nil)
            }
        }
    }
    
    /************/
    /* Check-In */
    /************/
    func setupBarButtonItems() {
        checkInButton = UIBarButtonItem(title: "Check-In", style: .plain, target: self, action: #selector(ClientViewController.checkInClicked))
        self.navigationItem.rightBarButtonItem = checkInButton
    }

    @objc func checkInClicked() {
        if let client = client {
            if (client.passes <= 0) {
                let noPassesAlert = UIAlertController(title: "!", message: "No passes remaining.\n\nPlease click more options to add a pass.", preferredStyle: UIAlertController.Style.alert)
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
        if (segue.identifier == "EditClient") {
            if let client = client {
                let controller = (segue.destination as! EditClientViewController)
                let backItem = UIBarButtonItem()
                backItem.title = "Back"
                navigationItem.backBarButtonItem = backItem
                controller.client = client
            }
        }
    }

    
}

