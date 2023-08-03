//
//  Constants.swift
//  FaceApp
//
//  Created by Abhishek Biswas on 31/07/23.
//

import Foundation
import UIKit


class Constants {
    static func makeAlert(controller : UIViewController?, msg: String, title: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default))
        controller?.present(alert, animated: true, completion: nil)
    }
}


protocol cleaningTextField {
    func cleaningTask()
}
