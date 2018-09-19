//
//  EditClientViewController.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/30/16.
//  Copyright © 2017 Jennifer Karavakis. All rights reserved.
//

import UIKit

class EditClientViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var numPassesLeftLabel: UILabel!
    @IBOutlet weak var numTotalCheckInsLabel: UILabel!
    @IBOutlet weak var numTotalPassesLabel: UILabel!
    @IBOutlet weak var priceTotalAmountPaidLabel: UILabel!
    @IBOutlet weak var activitiesTableView: UITableView!
    @IBOutlet weak var addPassButton: UIButton!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var passesLeftTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    var checkInButton: UIBarButtonItem!
    var checkInDatePicker = UIDatePicker()
    var passPickerView = UIPickerView()

    var client:Client? = nil //passed in from last view

    func reloadActivitiesTable() -> Void {
        activitiesTableView.reloadData()
        populateClientInfo()
    }

    override func viewDidLoad() {

        if let client = self.client {
            //Set header
            self.navigationItem.title = client.name
            reloadActivitiesTable()
        }
        super.viewDidLoad()
        setupBorders()
        setupPickerView()
        setupDatePicker()
        setupBarButtonItems()
        addKeyboardNotifications()
    }


    /*****************/
    /* Setup Borders */
    /*****************/
    func setupBorders() {
        //Notes
        self.notesTextView.layer.borderColor = UIColor.gray.cgColor
        self.notesTextView.layer.borderWidth = 1.0;
        self.notesTextView.layer.cornerRadius = 8;
    }


    /************************/
    /* Populate Client Info */
    /************************/
    func populateClientInfo() {
        if let client : Client = client {
            self.automaticallyAdjustsScrollViewInsets = false
            notesTextView.text = client.notes
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

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            if let client = client {
                func deleteSuccess() {
                    client.removeActivity(activityIndex: indexPath.row)
                    populateClientInfo()
                    tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                }

                func errorHandler(_ error: NSError) {
                    print("Error: \(error) \(error.userInfo)")
                }

                client.activities[indexPath.row].deleteRecord(deleteSuccess, errorHandler: errorHandler)
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

    func checkInClicked() {
        if let client = client {
            if (client.passes <= 0) {
                let noPassesAlert = UIAlertController(title: "Warning", message: "Client has no passes remaining.", preferredStyle: UIAlertController.Style.alert)
                noPassesAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
                }))
                noPassesAlert.addAction(UIAlertAction(title: "Check-in", style: .default, handler: { (action: UIAlertAction!) in
                    self.dateTextField.becomeFirstResponder()
                }))
                present(noPassesAlert, animated: true, completion: nil)
            }
            else {
                self.dateTextField.becomeFirstResponder()
            }
        }
    }

    @objc func checkInDoneClicked() {
        client!.checkIn(checkInDatePicker.date)
        _ = navigationController?.popViewController(animated: true)
        _ = navigationController?.popViewController(animated: true)
    }

    @objc func checkInCancelClicked() {
        dateTextField.resignFirstResponder()
    }

    /*********************/
    /* Setup Date Picker */
    /*********************/
    func setupDatePicker() {
        let today = Date()
        checkInDatePicker.datePickerMode = UIDatePicker.Mode.date
        checkInDatePicker.setDate(today, animated: false)
        checkInDatePicker.maximumDate = today

        dateTextField = UITextField();
        self.view.addSubview(dateTextField)
        dateTextField.inputView = checkInDatePicker
        dateTextField.isHidden = true

        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(EditClientViewController.checkInCancelClicked))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "Check-In", style: .plain, target: self, action: #selector(EditClientViewController.checkInDoneClicked))

        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        titleLabel.text = "Pick Check-In Date"
        titleLabel.textAlignment = NSTextAlignment.center
        let title = UIBarButtonItem(customView: titleLabel)

        let pickerToolbar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        pickerToolbar.setItems([cancelButton, flexSpace, title, flexSpace, doneButton], animated: true)
        dateTextField.inputAccessoryView = pickerToolbar
    }

    /************/
    /* Add Pass */
    /************/
    @IBAction func addPassClicked(_ sender: AnyObject) {
        performSegue(withIdentifier: "AddPassClicked", sender: self)
    }

    func passAddedHandler() {
        reloadActivitiesTable()
        populateClientInfo()
    }

    /**********************/
    /* Update Passes Left */
    /**********************/
    @IBAction func updatePassesLeftClicked(_ sender: AnyObject) {
        passesLeftTextField.text = numPassesLeftLabel.text
        passPickerView.selectRow(Int(passesLeftTextField.text!)!+999, inComponent: 0, animated: false)
        passesLeftTextField.becomeFirstResponder()
    }

    func setupPickerView() {
        passPickerView.delegate = self
        passesLeftTextField = UITextField();
        self.view.addSubview(passesLeftTextField)
        passesLeftTextField.inputView = passPickerView
        passesLeftTextField.isHidden = true

        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(EditClientViewController.cancelClicked))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(EditClientViewController.doneClicked))

        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        titleLabel.text = "Update Passes Left"
        titleLabel.textAlignment = NSTextAlignment.center
        let title = UIBarButtonItem(customView: titleLabel)

        let pickerToolbar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        pickerToolbar.setItems([cancelButton, flexSpace, title, flexSpace, doneButton], animated: true)
        passesLeftTextField.inputAccessoryView = pickerToolbar

        passesLeftTextField.text = "0"
    }

    @objc func cancelClicked() {
        passesLeftTextField.resignFirstResponder()
    }

    @objc func doneClicked() {
        passesLeftTextField.resignFirstResponder()
        if let passes = passesLeftTextField.text {
            if let passNumber = Int(passes) {
                if let client = client {
                    var newPassNumber = passNumber-999
                    newPassNumber = newPassNumber >= 999 || newPassNumber <= -999 ? 0 : newPassNumber
                    passPickerView.selectRow(newPassNumber+999, inComponent: 0, animated: false)
                    client.updatePassesLeft(newPassNumber, successHandler: populateClientInfo)
                }
            }
        }
    }

    func numberOfComponents(in: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1999
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row-999)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        passesLeftTextField.text = String(row)
    }


    /*************/
    /* Save Note */
    /*************/

    func saveNote() {
        if let client = client {
            client.updateNotes(notesTextView.text)
        }
    }

    /***********************/
    /* Keyboard moves view */
    /***********************/
    let MOVE_VIEW_ANIMATE_TIME : TimeInterval = 10

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint2: NSLayoutConstraint!
    @IBOutlet weak var topConstraint3: NSLayoutConstraint!
    @IBOutlet weak var topConstraint4: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    var originalTopConstraint : CGFloat!
    var originalTopConstraint2 : CGFloat!
    var originalTopConstraint3 : CGFloat!
    var originalTopConstraint4 : CGFloat!
    var originalBottomConstraint : CGFloat!

    func setOriginalConstraints() {
        self.originalTopConstraint = self.topConstraint.constant
        self.originalTopConstraint2 = self.topConstraint2.constant
        self.originalTopConstraint3 = self.topConstraint3.constant
        self.originalTopConstraint4 = self.topConstraint4.constant
        self.originalBottomConstraint = self.bottomConstraint.constant
    }

    func addKeyboardNotifications() {
        setOriginalConstraints()
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }

    //TODO pull into a new class so we can just import the class at the top instead of duplicating
    @objc func keyboardWillShow(notification:Notification) {
        resetConstraints()
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        if( notesTextView.isFirstResponder ) {
            UIView.animate(withDuration: MOVE_VIEW_ANIMATE_TIME, animations: { () -> Void in
                let shift = (self.notesTextView.frame.maxY - keyboardFrame.minY) > 0 ? self.notesTextView.frame.maxY - keyboardFrame.minY + 8 : 0
                self.bottomConstraint.constant += shift
                self.topConstraint.constant -= shift
                self.topConstraint2.constant -= shift
                self.topConstraint3.constant -= shift
                self.topConstraint4.constant -= shift
            })
        }
    }

    @objc func keyboardWillHide(notification:Notification) {
        resetConstraints()
        if( notesTextView.isFirstResponder ) {
            saveNote()
        }
    }

    func resetConstraints() {
        if (self.originalTopConstraint) != nil {
            UIView.animate(withDuration: MOVE_VIEW_ANIMATE_TIME, animations: { () -> Void in
                self.topConstraint.constant = self.originalTopConstraint
                self.topConstraint2.constant = self.originalTopConstraint2
                self.topConstraint3.constant = self.originalTopConstraint3
                self.topConstraint4.constant = self.originalTopConstraint4
                self.bottomConstraint.constant = self.originalBottomConstraint
            })
        }
    }
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
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
