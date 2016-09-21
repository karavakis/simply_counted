//
//  PassTableViewController.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 9/3/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import Parse

class PassTableViewController: UITableViewController {

    @IBOutlet weak var passTableView: UITableView!
    var passCollection = PassCollection()
    var passActivities = [String:[PassActivity]]()
    var passActivityMonths = [String]()
    var fullClientList = ClientCollection()
    var isSectionCollapsed = [Bool]()
    var isLoading = false


    func passesDidLoad() -> Void {
        isLoading = false
        passActivities = passCollection.passActivities
        passActivityMonths = Array(passActivities.keys)
        isSectionCollapsed = [Bool](count: passActivityMonths.count, repeatedValue: true)
        passTableView.reloadData()
    }

    override func viewDidLoad() {
        self.navigationItem.title = "Class Dates";
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        isLoading = true

        passCollection.load(passesDidLoad)
    }

    //TODO: Don't load events here, find a way to just load new ones.
    override func viewDidAppear(animated: Bool) {
        if( !isLoading ) {
            isLoading = true
            passCollection.load(passesDidLoad)
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isLoading {
            return 0
        }
        else {
            return passActivities.count
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isSectionCollapsed[section]) {
            return 0
        }
        return passActivities[passActivityMonths[section]]!.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell : SimpleLabelTableViewCell
        cell = tableView.dequeueReusableCellWithIdentifier("PassCell") as! SimpleLabelTableViewCell

        if let passActivityMothList = passActivities[passActivityMonths[indexPath.section]] {
            let passActivity = passActivityMothList[indexPath.row]
            if let client = fullClientList[passActivity.clientReference!.recordID] {
                cell.label.text = client.name
            }
            cell.label2.text = String(passActivity.passesAdded)
            cell.label3.text = "$" + String(passActivity.price)
        }


        return cell
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 18))
        headerView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)

        //Month Label
        let monthLabel = UILabel(frame: CGRectMake(10, 5, tableView.frame.size.width - 16, 18))
        monthLabel.font = UIFont.systemFontOfSize(14)
        monthLabel.textAlignment = NSTextAlignment.Left
        monthLabel.text = passActivityMonths[section]
        headerView.addSubview(monthLabel)

        //Price Label
        let priceLabel = UILabel(frame: CGRectMake(10, 5, tableView.frame.size.width - 16, 18))
        priceLabel.font = UIFont.systemFontOfSize(14)
        priceLabel.textAlignment = NSTextAlignment.Right
        var price : NSDecimalNumber = 0
        if let passActivityMonthList = passActivities[passActivityMonths[section]] {
            for passActivity in passActivityMonthList {
                price = NSDecimalNumber(string: passActivity.price).decimalNumberByAdding(price)
            }
        }
        priceLabel.text = "$" + String(price)
        headerView.addSubview(priceLabel)

        //Make collapsible
        let headerTapped = UITapGestureRecognizer (target: self, action:#selector(self.sectionHeaderTapped(_:)))
        headerView .addGestureRecognizer(headerTapped)

        return headerView
    }

    func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
        let indexPath : NSIndexPath = NSIndexPath(forRow: 0, inSection:(recognizer.view?.tag as Int!)!)
        if (indexPath.row == 0) {

            isSectionCollapsed[indexPath.section] = !isSectionCollapsed[indexPath.section]

            //reload specific section animated
            let range = NSMakeRange(indexPath.section, 1)
            let sectionToReload = NSIndexSet(indexesInRange: range)
            self.tableView.reloadSections(sectionToReload, withRowAnimation:UITableViewRowAnimation.Fade)
        }
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "passClicked") {
            let section = self.passTableView.indexPathForSelectedRow!.section
            let row = self.passTableView.indexPathForSelectedRow!.row
            if let passActivityMothList = passActivities[passActivityMonths[section]] {
                let passActivity = passActivityMothList[row]
                let client = fullClientList[passActivity.clientReference!.recordID]
                let controller = (segue.destinationViewController as! ClientViewController)
                controller.client = client
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

