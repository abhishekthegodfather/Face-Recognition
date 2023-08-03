//
//  ImageProcessing.swift
//  FaceApp
//
//  Created by Abhishek Biswas on 31/07/23.
//

import Foundation
import UIKit
import CoreML

class ImageProcessing {
    static let shared = ImageProcessing()
    private func getImageDetectionModel(controller: UIViewController?) -> DeepLabV3? {
        do{
            let config = MLModelConfiguration()
            let mlModel = try DeepLabV3(configuration: config)
            return mlModel
        }catch{
            Constants.makeAlert(controller: controller, msg: "Error in Processing Image", title: "Alert!!")
            return nil
        }
    }
    
    public func startPreprocessingImage(imageData: Data, controller: UIViewController?) -> UIImage? {
        guard let model = getImageDetectionModel(controller: controller) else { return nil }
        let initModelSize: CGFloat = 513
        guard let imageFromData = UIImage(data: imageData) else { return nil }
        let resizedImage = imageFromData.resized(to: CGSize(width: initModelSize, height: initModelSize), scale: 1)
        if let pixelImage = resizedImage.pixelBuffer(width: Int(initModelSize), height: Int(initModelSize)) {
            do {
                let outputPredPixelImage = try model.prediction(image: pixelImage)
                if let outputImage = outputPredPixelImage.semanticPredictions.image(min: 0, max: 1, axes: (0, 0, 1)) {
                    guard let outputCIImage = CIImage(image: outputImage) else { return nil }
                    if let maskedImage = outputCIImage.removeWhitePixels() {
                        if maskedImage.applyBlurEffect() != nil {
                            guard let resizedCIImage = CIImage(image: resizedImage) else {return nil}
                            guard let compositedImage = resizedCIImage.composite(with: maskedImage) else { return nil }
                            return UIImage(
                                ciImage: compositedImage,
                                scale: imageFromData.scale,
                                orientation: imageFromData.imageOrientation
                            ).resized(to: CGSize(width: imageFromData.size.width, height: imageFromData.size.height))
                        }
                    }
                }
            } catch {
                Constants.makeAlert(controller: controller, msg: "Error in Processing Image", title: "Alert!!!")
                return nil
            }
        }
        return nil
    }
    
    
    private func createCGImage(from pixelBuffer: CVPixelBuffer) -> CGImage? {
        let ciContext = CIContext()
        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        return ciContext.createCGImage(ciImage, from: ciImage.extent)
    }
    
    
}
