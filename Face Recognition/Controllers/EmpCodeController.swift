//
//  PreviewController.swift
//  Face Recognition
//
//  Created by Abhishek Biswas on 01/08/23.
//

import UIKit
import CoreData

class EmpCodeController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var employeeCode: UITextField!
    @IBOutlet weak var transferEmployeeCode: UIButton!
    @IBOutlet weak var newEmployee: UIButton!
    @IBOutlet weak var removeEmployee: UIButton!
    @IBOutlet weak var markAttendence: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        employeeCode.keyboardType = .numberPad
        employeeCode.addTarget(self, action: #selector(textField_editingChanged), for: .editingChanged)
        newEmployee.addTarget(self, action: #selector(newEmployeeAction(_ :)), for: .touchUpInside)
        markAttendence.addTarget(self, action: #selector(markAttendanceAction(_ :)), for: .touchUpInside)
        removeEmployee.addTarget(self, action: #selector(removeEmployeeAction(_ :)), for: .touchUpInside)
    }
    
    @objc func textField_editingChanged(sender:UITextField) {
        if sender.text?.count == 9 {
            view.endEditing(true)
        }
    }
    
    
    @objc func markAttendanceAction(_ sender: UIButton){
        guard let empTxt = employeeCode.text else {return}
        if empTxt.count == 9 {
            let cameraVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomCamera") as? CustomCamera
            cameraVC?.modalPresentationStyle = .fullScreen
            cameraVC?.isPhotoForAttendence = true
            cameraVC?.delegate = self
            cameraVC?.empCode = empTxt
            self.present(cameraVC ?? UIViewController(), animated: true, completion: nil)
        }else if empTxt.count > 9 {
            DispatchQueue.main.async {
                Constants.makeAlert(controller: self, msg: "Employee Code cannot exceed 9 Charater", title: "Alert!!")
            }
        }else if empTxt.count == 0 {
            DispatchQueue.main.async {
                Constants.makeAlert(controller: self, msg: "Employee Code cannot be blank", title: "Alert!!")
            }
        }else{
            DispatchQueue.main.async {
                Constants.makeAlert(controller: self, msg: "Employee Code cannot less than 9 Charater", title: "Alert!!")
            }
        }
    }
    
    @objc func newEmployeeAction(_ sender: UIButton){
        guard let empTxt = employeeCode.text else {return}
        if empTxt.count == 9 {
            let cameraVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomCamera") as? CustomCamera
            cameraVC?.modalPresentationStyle = .fullScreen
            cameraVC?.isPhotoForNew = true
            cameraVC?.delegate = self
            cameraVC?.empCode = empTxt
            self.present(cameraVC ?? UIViewController(), animated: true, completion: nil)
        }else if empTxt.count > 9 {
            DispatchQueue.main.async {
                Constants.makeAlert(controller: self, msg: "Employee Code cannot exceed 9 Charater", title: "Alert!!")
            }
        }else if empTxt.count == 0 {
            DispatchQueue.main.async {
                Constants.makeAlert(controller: self, msg: "Employee Code cannot be blank", title: "Alert!!")
            }
        }else{
            DispatchQueue.main.async {
                Constants.makeAlert(controller: self, msg: "Employee Code cannot less than 9 Charater", title: "Alert!!")
            }
        }
    }
    
    
    @objc func removeEmployeeAction(_ sender: UIButton){
        guard let empTxt = employeeCode.text else {return}
        if empTxt.count == 9 {
            guard let context = ((UIApplication.shared.delegate) as? AppDelegate)?.persistentContainer.viewContext else {return}
            let request : NSFetchRequest<Employee> = Employee.fetchRequest()
            request.predicate = NSPredicate(format: "emp_code == %@", empTxt)
            request.fetchLimit = 1
            do{
                let employee = try context.fetch(request)
                guard let firstItem = employee.first else {return}
                context.delete(firstItem)
                print("Deleted Sucessfully")
                ((UIApplication.shared.delegate) as? AppDelegate)?.saveContext()
                Constants.makeAlert(controller: self, msg: "Deleted Sucessfully User", title: "Alert!!")
                self.employeeCode.text = ""
            }catch{
                Constants.makeAlert(controller: self, msg: "Cannot Delete Item From DB", title: "Error!!")
            }
        }else if empTxt.count > 9 {
            DispatchQueue.main.async {
                Constants.makeAlert(controller: self, msg: "Employee Code cannot exceed 9 Charater", title: "Alert!!")
            }
        }else if empTxt.count == 0 {
            DispatchQueue.main.async {
                Constants.makeAlert(controller: self, msg: "Employee Code cannot be blank", title: "Alert!!")
            }
        }else{
            DispatchQueue.main.async {
                Constants.makeAlert(controller: self, msg: "Employee Code cannot less than 9 Charater", title: "Alert!!")
            }
        }
        
    }
}

extension EmpCodeController : cleaningTextField {
    func cleaningTask() {
        self.employeeCode.text = ""
    }
}
