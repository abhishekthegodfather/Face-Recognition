//
//  ExtensionCC.swift
//  Face Recognition
//
//  Created by Abhishek Biswas on 01/08/23.
//

import Foundation
import UIKit
import CoreData

extension CustomCamera {
    func detectFaceInImage(imageDataArray: [Data], employeeModel: EmployeeModel){
        guard let lastFreshImage = imageDataArray.last else {return}
        FaceProcessing.shared.detectFaces(faceImageData: lastFreshImage) { result in
            print(result)
            if result > 1 {
                DispatchQueue.main.async {
                    Constants.makeAlert(controller: self, msg: "Multiple Face Found", title: "Alert!!")
                }
            }else if(result == 0){
                DispatchQueue.main.async {
                    Constants.makeAlert(controller: self, msg: "No Face Found", title: "Alert!!")
                }
            }else if(result == 1){
                self.prepareForImageProcessing(imageData: lastFreshImage, employeeModel: employeeModel)
            }
        }
    }
    
    
    func prepareForImageProcessing(imageData: Data, employeeModel: EmployeeModel){
        guard let tempImageData = UIImage(data: imageData)?.rotated(by: -360).pngData() else {return}
        guard let processedResImage = ImageProcessing.shared.startPreprocessingImage(imageData: tempImageData, controller: self) else {return}
        Recognition.shared.isFaceSimilarOrNot(testImage: processedResImage, trainImage: UIImage(data: employeeModel.imageData ?? Data()) ?? UIImage()) { result in
            if result {
                DispatchQueue.main.async {
                    self.laodingIndicator.stopAnimating()
                    self.laodingLabel.text = "Similar Face Found"
                    self.loadingView.isHidden = true
                    let alert = UIAlertController(title: "Alert!!", message: "Similar Face", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
                        alert.dismiss(animated: true){
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                                self.session?.stopRunning()
                                self.dismiss(animated: true) {
                                    self.delegate?.cleaningTask()
                                }
                            }
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }else{
                DispatchQueue.main.async {
                    self.laodingIndicator.stopAnimating()
                    self.laodingLabel.text = "Similar Face Not Found"
                    self.loadingView.isHidden = true
                    let alert = UIAlertController(title: "Alert!!", message: "No Similar Face", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
                        alert.dismiss(animated: true){
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                                self.session?.stopRunning()
                                self.dismiss(animated: true) {
                                    self.delegate?.cleaningTask()
                                }
                            }
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    
    func saveImageToCoreData(imageDataArray: [Data], emp_code: String){
        guard let lastFreshImage = imageDataArray.last else { return }
        guard let context = ((UIApplication.shared.delegate) as? AppDelegate)?.persistentContainer.viewContext else { return }
        do {
            let employeeItem = Employee(context: context)
            employeeItem.emp_code = emp_code
            employeeItem.emp_image = lastFreshImage
            try context.save()
            print("Employee data saved successfully!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.laodingIndicator.stopAnimating()
                self.laodingLabel.text = "Saved User"
                self.loadingView.isHidden = true
                
                let alert = UIAlertController(title: "Alert!!", message: "Saved User In DB Sucessfully", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
                    alert.dismiss(animated: true){
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3){
                            self.session?.stopRunning()
                            self.dismiss(animated: true) {
                                self.delegate?.cleaningTask()
                            }
                        }
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            }
        } catch let error {
            print("Error while inserting data into Core Data: \(error.localizedDescription)")
            let alert = UIAlertController(title: "Alert!!", message: "Cannot Insert Member in Core Data", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
                alert.dismiss(animated: true){
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3){
                        self.session?.stopRunning()
                        self.dismiss(animated: true) {
                            self.delegate?.cleaningTask()
                        }
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }

    }
    
    
    func fetchImageAccordingToEmpCode(emp_code: String?){
        self.loadingView.isHidden = false
        self.laodingIndicator.startAnimating()
        self.laodingLabel.text = "fetching user according to Employee code"
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2){
            guard let empCode = emp_code else {return}
            guard let context = ((UIApplication.shared.delegate) as? AppDelegate)?.persistentContainer.viewContext else { return }
            let request : NSFetchRequest<Employee> = Employee.fetchRequest()
            request.predicate = NSPredicate(format: "emp_code == %@", empCode)
            request.fetchLimit = 1
            do{
                let employee = try context.fetch(request)
                if employee.isEmpty {
                    self.laodingLabel.text = "User Not Exist"
                    self.laodingIndicator.stopAnimating()
                    self.loadingView.isHidden = true
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Alert!!", message: "User Not Found, Try to Register", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
                            alert.dismiss(animated: true){
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3){
                                    self.session?.stopRunning()
                                    self.dismiss(animated: true) {
                                        self.delegate?.cleaningTask()
                                    }
                                }
                            }
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                guard let firstItem = employee.first else {return}
                let singleTempModel : EmployeeModel = EmployeeModel(empCode: firstItem.emp_code ?? "", imageData: firstItem.emp_image ?? Data())
                self.laodingIndicator.stopAnimating()
                self.loadingView.isHidden = true
                self.takePhotoEveryDelay(employeeModel: singleTempModel)
            }catch{
                Constants.makeAlert(controller: self, msg: "Cannot Fetch Member From DB", title: "Error!!")
            }
        }
    }
}
