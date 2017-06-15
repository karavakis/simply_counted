//
//  AddPassViewController.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 9/2/16.
//  Copyright © 2017 Jennifer Karavakis. All rights reserved.
//

import UIKit
import LocalAuthentication

class AddPassViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var client : Client? = nil
    var passTypes = PassTypeCollection()
    @IBOutlet weak var passTypeTableView: UITableView!
    var isLoading = false
    var passAddedHandler:(()->Void)!

    func passTypesDidLoad() -> Void {
        isLoading = false
        passTypeTableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        isLoading = true
        passTypes.load(passTypesDidLoad)

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*******************/
    /* Load Table View */
    /*******************/
    func numberOfSections(in tableView: UITableView) -> Int {
        if isLoading {
            return 1
        }
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return 1
        }
        else {
            return passTypes.count()
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var returnCell : UITableViewCell

        if(indexPath.section == 0) {
            var cell : AddPassTypeTableViewCell
            cell = tableView.dequeueReusableCell(withIdentifier: "AddPassTypeCell") as! AddPassTypeTableViewCell

            func completionHandler(_ passType: PassType) -> Void {
                passTypes.add(passType)
                self.passTypeTableView.reloadData()
            }

            cell.completionHandler = completionHandler

            returnCell = cell
        }
        else {
            var cell : SimpleLabelTableViewCell
            cell = tableView.dequeueReusableCell(withIdentifier: "PassTypeCell") as! SimpleLabelTableViewCell
            if let passType = passTypes[indexPath.row] {
                cell.label.text = String(passType.passCount) + " Pass"
                cell.label2.text = "$" + String(describing: passType.price) //TODO check
            }
            returnCell = cell
        }

        return returnCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section > 0) {
            self.dismiss(animated: true, completion: nil)
            if let passType = passTypes[indexPath.row] {
                if let client = client {
                    client.addPasses(passType)
                    if self.passAddedHandler != nil {
                        self.passAddedHandler()
                    }
                }
            }
        }
        else {
            tableView.cellForRow(at: indexPath)?.isSelected = false
        }
    }

    internal func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {

            func deleteSuccess() {
                passTypes.removeAtIndex(indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }

            func errorHandler(_ error: NSError) {
                print("Error: \(error) \(error.userInfo)")
            }

            passTypes[indexPath.row]?.deleteRecord(deleteSuccess, errorHandler: errorHandler)
        }
    }

}
