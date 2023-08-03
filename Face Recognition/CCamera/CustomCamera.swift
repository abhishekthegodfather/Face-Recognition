//
//  Custom Camera.swift
//  FaceApp
//
//  Created by Abhishek Biswas on 31/07/23.
//

import AVFoundation
import  UIKit

class CustomCamera : UIViewController {
    
    @IBOutlet weak var previewCamView : UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var laodingLabel: UILabel!
    @IBOutlet weak var laodingIndicator: UIActivityIndicatorView!
    
    
    let NUM_OF_PHOTO = 3
    var empCode : String?
    var isPhotoForAttendence = false
    var isPhotoForNew = false
    var session : AVCaptureSession?
    let output = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var imgData : [Data] = []
    var delegate : cleaningTextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraPermission()
        self.previewCamView.layer.addSublayer(previewLayer)
        self.loadingView.isHidden = true
        if isPhotoForAttendence {
            fetchImageAccordingToEmpCode(emp_code: self.empCode)
        }else if isPhotoForNew {
            takePhotoEveryDelayForNew()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = self.previewCamView.bounds
    }
    
    func takePhotoEveryDelayForNew() {
        guard let empCode = self.empCode else {return}
        var photosTaken = 0
        func capturePhotoForNew() {
            output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            photosTaken += 1
            if photosTaken == NUM_OF_PHOTO {
                self.loadingView.isHidden = false
                self.laodingIndicator.startAnimating()
                self.laodingLabel.text = "Saving User in Database"
                self.saveImageToCoreData(imageDataArray: self.imgData, emp_code: empCode)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: capturePhotoForNew)
            }
        }
        capturePhotoForNew()
    }
    
    
    func takePhotoEveryDelay(employeeModel: EmployeeModel) {
        var photosTaken = 0
        func capturePhoto() {
            output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            photosTaken += 1
            if photosTaken == NUM_OF_PHOTO {
                DispatchQueue.main.async {
                    self.laodingIndicator.startAnimating()
                    self.loadingView.isHidden = false
                    self.laodingLabel.text = "wait for 15 second, verifing user"
                }
                self.detectFaceInImage(imageDataArray: self.imgData, employeeModel: employeeModel)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: capturePhoto)
            }
        }
        capturePhoto()
    }
    
    private func checkCameraPermission(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .notDetermined:
            // Request For Camera Prmissions
            AVCaptureDevice.requestAccess(for: .video) { [weak self] result in
                guard let self = self else {return}
                guard result else {return}
                DispatchQueue.main.async {
                    self.setupCamera()
                }
            }
            break
        case .restricted:
            Constants.makeAlert(controller: self, msg: "No Camera Permissions", title: "Alert!!")
            break
        case .denied:
            Constants.makeAlert(controller: self, msg: "No Camera Permissions", title: "Alert!!")
            break
        case .authorized:
            self.setupCamera()
            break
        @unknown default:
            Constants.makeAlert(controller: self, msg: "No Camera Permissions", title: "Alert!!")
            break
        }
    }
    
    private func setupCamera() {
        let session = AVCaptureSession()
        if let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            do {
                let input = try AVCaptureDeviceInput(device: backCamera)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                self.previewLayer.videoGravity = .resizeAspectFill
                self.previewLayer.session = session
                DispatchQueue.global(qos: .background).async {
                    session.startRunning()
                }
                self.session = session
            } catch {
                Constants.makeAlert(controller: self, msg: "Error in Setup Camera", title: "Alert!!")
            }
        }
    }
}


extension CustomCamera : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {return}
        self.imgData.append(data)
    }
}


