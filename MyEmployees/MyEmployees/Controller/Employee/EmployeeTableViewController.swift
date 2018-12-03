//
//  EmployeeTableViewController.swift
//  MyEmployees
//
//  Created by Daniel Rodrigues on 21/10/18.
//  Copyright © 2018 danitrod. All rights reserved.
//

import UIKit
import os.log

class EmployeeTableViewController: UITableViewController {
    
    //MARK: Properties
    
    //Dictionary with employees list for each department id
    var allEmployees = [Int: [Employee]]()
    
    //List with selected department employees
    var departmentsEmployees = [Employee]()
    
    //Employee's belonging department (passed from NewDepartment's goToButton)
    var department:Department?
    
    //List of departments and index of selected department passed for saving
    var departments = [Department]()
    var indexOfDepartment:Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting bar title to the department's initials
        if department != nil {
            navigationItem.title = department!.initials
        }
        else {
            fatalError("No department was passed to employee table view")
        }
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        //Loading employees for selected department
        if let savedEmployees = loadEmployees() {
            allEmployees = savedEmployees
            if let departmentsEmployees = allEmployees[department!.id] {
                self.departmentsEmployees += departmentsEmployees
            }
        }
    }

    // MARK: Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return departmentsEmployees.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "EmployeeCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? EmployeeTableViewCell  else {
            fatalError("The dequeued cell is not an instance of EmployeeTableViewCell.")
        }
        
        // Fetches the appropriate department for the data source layout.
        let employee = departmentsEmployees[indexPath.row]
        
        cell.nameLabel.text = employee.name
        cell.idLabel.text = "Id: \(employee.id)"
        cell.departmentIdLabel.text = "Department Id: \(employee.departmentId)"
        cell.rgLabel.text = "RG: \(employee.rg)"
        cell.photoImageView.image = employee.photo ?? nil
        
        return cell
    }
    
    //MARK: Actions
    
    //When pressing the back button, go back do new department view.
    @IBAction func back(_ sender: UIBarButtonItem) {
        saveEmployees()
        dismiss(animated: true, completion: nil)
    }
    
    //When pressing add button, present modally the new employee view.
    @IBAction func addEmployee(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Employee", bundle: nil)
        guard let newController = storyboard.instantiateViewController(withIdentifier: "newEmployeeController") as? NewEmployeeViewController else {
            fatalError("Unable to instantiate new employee view.")
        }
        let navigationController = UINavigationController(rootViewController: newController)
        newController.department = department
        self.present(navigationController, animated: true, completion: nil)
        
    }
    
    @IBAction func unwindToEmployeeList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? NewEmployeeViewController, let employee = sourceViewController.employee {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing employee.
                departmentsEmployees[selectedIndexPath.row] = employee
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new employee.
                let newIndexPath = IndexPath(row: departmentsEmployees.count, section: 0)
                
                departmentsEmployees.append(employee)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            saveEmployees()
        }
    }
    
    //MARK: Private methods
    
    //Saving/Loading employees methods
    private func saveEmployees() {
        //The dictionary with all the employees is saved when saving.
        allEmployees[department!.id]=departmentsEmployees
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(allEmployees, toFile: Employee.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Employees successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save employees...", log: OSLog.default, type: .error)
        }
        //Save departments as well to keep the employeeNumber variable.
        departments[indexOfDepartment!]=department!
        let isSuccessfulSave2 = NSKeyedArchiver.archiveRootObject(departments, toFile: Department.ArchiveURL.path)
        if isSuccessfulSave2 {
            os_log("Departments successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save departments...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadEmployees() -> [Int: [Employee]]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Employee.ArchiveURL.path) as? [Int: [Employee]]
    }

    //MARK: Table View cell
    
    // Support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            departmentsEmployees.remove(at: indexPath.row)
            saveEmployees()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "AddItem":
            os_log("Adding a new employee.", log: OSLog.default, type: .debug)
            
        case "EditDetail":
            guard let employeeDetailViewController = segue.destination as? NewEmployeeViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            employeeDetailViewController.department = department
            
            guard let selectedEmployeeCell = sender as? EmployeeTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedEmployeeCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedEmployee = departmentsEmployees[indexPath.row]
            employeeDetailViewController.employee = selectedEmployee
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    

}
