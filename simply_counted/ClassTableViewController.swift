//
//  ClassTableViewController.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/21/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//
import UIKit

class ClassTableViewController: UITableViewController {

    @IBOutlet weak var classTableView: UITableView!
    var classes = ClassCollection()
    var fullClientList = ClientCollection()
    var isLoading = false
    

    func classesDidLoad() -> Void {
        isLoading = false
        classTableView.reloadData()
    }

    override func viewDidLoad() {
        self.navigationItem.title = "Class Dates";
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        isLoading = true

        classes.load(classesDidLoad)
    }

    //TODO: Don't load events here, find a way to just load new ones.
    override func viewDidAppear(_ animated: Bool) {
        if( !isLoading ) {
            isLoading = true
            classes.load(classesDidLoad)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isLoading {
            return 0
        }
        else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell : SimpleLabelTableViewCell
        cell = tableView.dequeueReusableCell(withIdentifier: "ClassCell") as! SimpleLabelTableViewCell

        //TODO add errors
        if let classDate = classes[indexPath.row] {

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.full
            dateFormatter.timeStyle = DateFormatter.Style.none
            cell.label.text = dateFormatter.string(from: classDate.date)

            cell.label2.text = String(classDate.checkIns.count)
        }


        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "classClicked") {
            let controller = (segue.destination as! ClientTableViewController)
            let row = self.classTableView.indexPathForSelectedRow!.row
            let classDate = classes[row]
            if let classDate = classDate {
                controller.classDate = classDate
                controller.fullClientList = fullClientList
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

