//
//  Employee.swift
//  Face Recognition
//
//  Created by Abhishek Biswas on 03/08/23.
//

import Foundation


class EmployeeModel {
    var empCode: String
    var imageData : Data?
    
    init(empCode: String, imageData: Data? = nil) {
        self.empCode = empCode
        self.imageData = imageData
    }
}
