//
//  NotesViewController.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/30/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {
    var client:Client? = nil //passed in from last view
    @IBOutlet weak var notesTextField: UITextView!

    override func viewDidLoad() {
        setupBarButtonItems()
        self.navigationItem.title = client!.name;
        super.viewDidLoad()
        notesTextField.text = client!.notes
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
        navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
