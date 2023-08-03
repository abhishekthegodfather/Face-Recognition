//
//  FaceProcessing.swift
//  FaceApp
//
//  Created by Abhishek Biswas on 31/07/23.
//

import Vision
import UIKit

class FaceProcessing {
    static let shared = FaceProcessing()
    
    public func detectFaces(faceImageData: Data, compleation: @escaping (Int) -> Void) {
        guard let faceImg : UIImage = UIImage(data: faceImageData) else {return}
        if let cgImageFace = faceImg.cgImage {
            let visionImageHandler = VNImageRequestHandler(cgImage: cgImageFace, options: [:])
            let faceDetctionRequest = VNDetectFaceRectanglesRequest { request, error in
                if let error = error {
                    print("Error in face detection: \(error.localizedDescription)")
                    compleation(0)
                } else if let results = request.results as? [VNFaceObservation] {
                    let faceCount = results.count
                    compleation(faceCount)
                } else {
                    compleation(0)
                }
            }

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try visionImageHandler.perform([faceDetctionRequest])
                } catch {
                    print("Error in face detection request: \(error.localizedDescription)")
                    compleation(0)
                }
            }
        }
    }
}
