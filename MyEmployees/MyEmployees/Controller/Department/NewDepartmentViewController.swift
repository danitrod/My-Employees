//
//  NewDepartmentViewController.swift
//  MyEmployees
//
//  Created by Daniel Rodrigues on 21/10/18.
//  Copyright © 2018 danitrod. All rights reserved.
//

import UIKit
import os.log

class NewDepartmentViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var initialsTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var goToButton: UIButton!
    
    /*
     This value is either passed by `DepartmentTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new department.
     */
    var department: Department?
    
    //List of departments and index of selected department to be passed on for saving
    var departments = [Department]()
    var indexOfDepartment: Int?
    
    //These value is kept when editing a department
    var existingId: Int?
    var existingNumberOfEmployees: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting delegates
        nameTextField.delegate = self
        initialsTextField.delegate = self
        
        // Set up views if editing an existing Department.
        if let department = department {
            nameTextField.text = department.name
            initialsTextField.text = department.initials.uppercased()
            existingId = department.id
            existingNumberOfEmployees = department.numberOfEmployees
            navigationItem.title = department.initials
        }
        
        //Enabling goToButton if department is saved
        updateGoToButtonState()
        
        //Enabling saveButton if name&initials are not nil
        updateSaveButtonState()
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    //MARK: Actions
    
    //Go to employee list button, up setting the correct preparation.
    @IBAction func goToEmployeeList(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Employee", bundle: nil)
        guard let listController = storyboard.instantiateViewController(withIdentifier: "employeeTableViewController") as? EmployeeTableViewController else {
            fatalError("Unable to instantiate employee list.")
        }
        let navigationController = UINavigationController(rootViewController: listController)
        listController.department = department
        listController.departments = departments
        listController.indexOfDepartment = indexOfDepartment
        self.present(navigationController, animated: true, completion: nil)
    }
    
    
    //MARK: Private Methods
    
    private func updateSaveButtonState() {
        // Disable the save button if either text field is empty.
        let text = nameTextField.text ?? ""
        let text2 = initialsTextField.text ?? ""
        saveButton.isEnabled = !(text2.isEmpty || text.isEmpty)
    }
    
    
    private func updateGoToButtonState() {
        goToButton.isEnabled = (department != nil)
    }

    // MARK: - Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddDepartmentMode = presentingViewController is UINavigationController
        
        if isPresentingInAddDepartmentMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The DepartmentViewController is not inside a navigation controller.")
        }
    }

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = nameTextField.text!
        let initials = initialsTextField.text!.uppercased()
        let id = existingId ?? nil
        let numberOfEmployees = existingNumberOfEmployees ?? nil
        
        // Set the department to be passed to DepartmentTableViewController after the unwind segue.
        department = Department(name: name, initials: initials, id: id, numberOfEmployees: numberOfEmployees)
    }
}
