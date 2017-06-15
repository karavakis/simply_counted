//
//  ClientTableViewController.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/22/16.
//  Copyright © 2017 Jennifer Karavakis. All rights reserved.
//

import UIKit

class ClientTableViewController: UITableViewController {

    @IBOutlet weak var clientTableView: UITableView!
    var classDate = ClassDate()
    var fullClientList = ClientCollection()
    var sortedClientList = [Client]()

    override func viewDidLoad() {
        //Sort clients
        for checkIn in classDate.checkIns {
            if let client = fullClientList[checkIn.clientReference!.recordID] {
                sortedClientList.append(client)
            }
        }

        sortedClientList.sort { $0.name.compare($1.name) == .orderedAscending }

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //TODO: Don't load events here, find a way to just load new ones.
    override func viewDidAppear(_ animated: Bool) {
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedClientList.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {//Set header
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d, yyyy"

        return dateFormatter.string(from: classDate.date) + " - " + String(classDate.checkIns.count) + " students"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell : SimpleLabelTableViewCell
        cell = tableView.dequeueReusableCell(withIdentifier: "ClientCell") as! SimpleLabelTableViewCell

        //TODO add errors
        let client = sortedClientList[indexPath.row]

        cell.label.text = client.name

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ClientClicked", sender: self);
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "ClientClicked") {
            let controller = (segue.destination as! ClientViewController)
            let row = self.clientTableView.indexPathForSelectedRow!.row
            let client = sortedClientList[row]
            controller.client = client
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

