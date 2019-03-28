//
//  PassTableViewController.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 9/3/16.
//  Copyright © 2017 Jennifer Karavakis. All rights reserved.
//

import UIKit

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
        isSectionCollapsed = [Bool](repeating: true, count: passActivityMonths.count)
        if(isSectionCollapsed.count > 0) {
            isSectionCollapsed[0] = false
        }
        passTableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        isLoading = true

        passCollection.load(passesDidLoad)
    }

    //TODO: Don't load events here, find a way to just load new ones.
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.view.backgroundColor = UIColor.white
        self.tabBarController?.navigationItem.title = "Passes"

        if( !isLoading ) {
            isLoading = true
            passCollection.load(passesDidLoad)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isLoading {
            return 0
        }
        else {
            return passActivities.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isSectionCollapsed[section]) {
            return 0
        }
        return passActivities[passActivityMonths[section]]!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell : SimpleLabelTableViewCell
        cell = tableView.dequeueReusableCell(withIdentifier: "PassCell") as! SimpleLabelTableViewCell

        if let passActivityMothList = passActivities[passActivityMonths[indexPath.section]] {
            let passActivity = passActivityMothList[indexPath.row]
            if let client = fullClientList[passActivity.clientReference!.recordID] {
                cell.label.text = client.name
            }
            cell.label2.text = String(passActivity.passesAdded)
            cell.label3.text = "$" + passActivity.price
        }

        return cell
    }

    // Need to have this for the headers to work for some reason
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "section"
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 18))
        headerView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)

        headerView.tag = section

        //Month Label
        let monthLabel = UILabel(frame: CGRect(x: 10, y: 5, width: tableView.frame.size.width - 16, height: 18))
        monthLabel.font = UIFont.systemFont(ofSize: 14)
        monthLabel.textAlignment = NSTextAlignment.left
        let arrow = isSectionCollapsed[section] ? "\u{25b6}   " : "\u{25bc}   "
        monthLabel.text = arrow + passActivityMonths[section]
        headerView.addSubview(monthLabel)

        //Price Label
        let priceLabel = UILabel(frame: CGRect(x: 10, y: 5, width: tableView.frame.size.width - 16, height: 18))
        priceLabel.font = UIFont.systemFont(ofSize: 14)
        priceLabel.textAlignment = NSTextAlignment.right
        var price : NSDecimalNumber = 0
        if let passActivityMonthList = passActivities[passActivityMonths[section]] {
            for passActivity in passActivityMonthList {
                price = NSDecimalNumber(string: passActivity.price).adding(price)
            }
        }
        priceLabel.text = "$" + String(describing: price)
        headerView.addSubview(priceLabel)

        //Make collapsible
        let headerTapped = UITapGestureRecognizer (target: self, action:#selector(self.sectionHeaderTapped(_:)))
        headerView .addGestureRecognizer(headerTapped)

        return headerView
    }

    @objc func sectionHeaderTapped(_ recognizer: UITapGestureRecognizer) {
        let indexPath : IndexPath = IndexPath(row: 0, section:(recognizer.view?.tag as Int?)!)
        if (indexPath.row == 0) {

            isSectionCollapsed[indexPath.section] = !isSectionCollapsed[indexPath.section]

            //reload specific section animated
            let range = NSRange(location: indexPath.section, length:1)
            let sectionToReload = IndexSet(integersIn: Range(range) ?? 0..<0)
            self.tableView.reloadSections(sectionToReload, with:UITableView.RowAnimation.fade)
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "passClicked") {
            let section = self.passTableView.indexPathForSelectedRow!.section
            let row = self.passTableView.indexPathForSelectedRow!.row
            if let passActivityMothList = passActivities[passActivityMonths[section]] {
                let passActivity = passActivityMothList[row]
                let client = fullClientList[passActivity.clientReference!.recordID]
                let controller = (segue.destination as! ClientViewController)
                controller.client = client
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

