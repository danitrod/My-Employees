//
//  NewEmployeeViewController.swift
//  MyEmployees
//
//  Created by Daniel Rodrigues on 22/10/18.
//  Copyright © 2018 danitrod. All rights reserved.
//

import UIKit
import os.log

class NewEmployeeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var rgTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //Passed from department view
    var department:Department?
    
    //Passed object for editing or object to be created
    var employee:Employee?
    
    //Id to be preserved if editing
    var existingId:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Check if department was passed
        if department == nil {
            fatalError("No department was passed to new employee view.")
        }
        
        //Setup delegates
        nameTextField.delegate = self
        rgTextField.delegate = self
        
        //Setup editing
        if let employee = employee {
            nameTextField.text = employee.name
            rgTextField.text = employee.rg
            existingId = employee.id
            photoImageView.image = employee.photo
        }
    }
    
    //MARK: Actions
    
    @IBAction func changePhoto(_ sender: UITapGestureRecognizer) {
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: Image Picker
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
    }
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
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
    
    //MARK: Private methods
    
    private func updateSaveButtonState() {
        // Disable the Save button if either text field is empty.
        let text = nameTextField.text ?? ""
        let text2 = rgTextField.text ?? ""
        saveButton.isEnabled = !(text2.isEmpty || text.isEmpty)
    }


    // MARK: - Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
        else {
            fatalError("The NewEmployeeViewController is not inside a navigation controller.")
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = nameTextField.text ?? ""
        let photo = photoImageView.image
        let rg = rgTextField.text ?? ""
        
        //Setting id based on number of employees in department
        var id:Int
        var hasExistingId: Bool
        if existingId == nil {
            if department!.numberOfEmployees == nil {
                department!.numberOfEmployees = 1
            }
            else {
                department!.numberOfEmployees!+=1
            }
            id = department!.numberOfEmployees!
            hasExistingId = false
        }
        else {
            id = existingId!
            hasExistingId = true
        }
        
        
        // Set the employee to be passed to EmployeeTableViewController after the unwind segue.
        employee = Employee(name: name, photo: photo, rg: rg, departmentId: self.department!.id, id: id, hasExistingId: hasExistingId)
    }
 
    

}
