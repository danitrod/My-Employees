//
//  DepartmentTableViewController.swift
//  MyEmployees
//
//  Created by Daniel Rodrigues on 21/10/18.
//  Copyright © 2018 danitrod. All rights reserved.
//

import UIKit
import os.log

class DepartmentTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var departments = [Department]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Load any saved departments, otherwise load sample data.
        if let savedDepartments = loadDepartments() {
            departments += savedDepartments
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return departments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "DepartmentCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DepartmentTableViewCell  else {
            fatalError("The dequeued cell is not an instance of DepartmentTableViewCell.")
        }
        
        // Fetches the appropriate department for the data source layout.
        let department = departments[indexPath.row]
        
        cell.nameLabel.text = department.name
        cell.idLabel.text = "Id: \(department.id)"
        cell.initialsLabel.text = department.initials
        
        return cell
    }
    
    //MARK: Actions
    
    @IBAction func unwindToDepartmentList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? NewDepartmentViewController, let department = sourceViewController.department {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing department.
                departments[selectedIndexPath.row] = department
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new department.
                let newIndexPath = IndexPath(row: departments.count, section: 0)
                
                departments.append(department)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            // Save the departments.
            saveDepartments()
        }
    }
    
    //MARK: Private Methods
    
    private func saveDepartments() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(departments, toFile: Department.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Departments successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save departments...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadDepartments() -> [Department]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Department.ArchiveURL.path) as? [Department]
    }
    
    // Support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    
    // Support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            departments.remove(at: indexPath.row)
            saveDepartments()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new department.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let departmentDetailViewController = segue.destination as? NewDepartmentViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedDepartmentCell = sender as? DepartmentTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedDepartmentCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedDepartment = departments[indexPath.row]
            departmentDetailViewController.department = selectedDepartment
            departmentDetailViewController.departments = departments
            departmentDetailViewController.indexOfDepartment = indexPath.row
        
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    

}
