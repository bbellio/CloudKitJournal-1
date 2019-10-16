//
//  EntryDetailViewController.swift
//  JournalCloudKit
//
//  Created by Bethany Wride on 10/14/19.
//  Copyright © 2019 Bethany Wride. All rights reserved.
//

import UIKit

class EntryDetailViewController: UIViewController {
    // MARK: - Global variables
    var entry: Entry? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDesign()
    }
    
    // MARK: - Actions
    @IBAction func clearButtonTapped(_ sender: Any) {
        titleTextField.text = ""
        bodyTextView.text = ""
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text,
            let bodyText = bodyTextView.text,
            !title.isEmpty, !bodyText.isEmpty else { return }
        if let entry = entry {
            EntryController.sharedInstance.update(entry: entry) { (success) in
                if success {
                    entry.title = title ; entry.bodyText = bodyText ; entry.timestamp = Date()
                    EntryController.sharedInstance.save(entry: entry) { (success) in
                        print("Saved newly updated entry")
                    }
                    self.returnToListView()
                    print("Entry was successfully updated")
                }
            }
        } else {
            EntryController.sharedInstance.createEntry(with: title, bodyText: bodyText) { (success) in
                if success {
                    self.returnToListView()
                    print("Entry succesfully added")
                } else {
                    print("New entry was not saved")
                }
            }
        }
    } // End of function
    
    @IBAction func mainViewTapped(_ sender: Any) {
        bodyTextView.resignFirstResponder()
        titleTextField.resignFirstResponder()
    }
    
    // MARK: - Custom Functions
    func updateDesign() {
        bodyTextView.layer.borderColor = UIColor.blue.cgColor
        bodyTextView.layer.borderWidth = 1
        bodyTextView.layer.cornerRadius = 5
    }
    
    func updateViews() {
        if let entry = entry {
            titleTextField.text = entry.title
            bodyTextView.text = entry.bodyText
        }
    }
    
    func returnToListView() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
} // End of class

extension EntryDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
    }
}
