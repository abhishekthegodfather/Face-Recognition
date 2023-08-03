//
//  Recognition.swift
//  Face Recognition
//
//  Created by Abhishek Biswas on 01/08/23.
//

import Foundation
import FaceSDK
import UIKit

class Recognition {
    static let shared = Recognition()
    private let thresholdForRecognition = 0.8
    
    private func getSimilarityMatrix(testImage: Data, trainImage: Data, compleation: @escaping(([MatchFacesComparedFacesPair]?) -> Void)) {
        guard let testImageFromData = UIImage(data: testImage) , let trainImageFromData = UIImage(data: trainImage) else {
            compleation(nil)
            return
        }
        let images = [
            MatchFacesImage(image: testImageFromData, imageType: .printed),
            MatchFacesImage(image: trainImageFromData, imageType: .printed),
        ]
        let request = MatchFacesRequest(images: images)
        FaceSDK.service.matchFaces(request, completion: { response in
            compleation(response.results)
        })
    }
    
    public func isFaceSimilarOrNot(testImage: UIImage, trainImage: UIImage, simlarityCompleation: @escaping((Bool) -> Void)){
        guard let testImageData = testImage.pngData(), let trainImageData = trainImage.pngData() else {return}
        Recognition.shared.getSimilarityMatrix(testImage: testImageData, trainImage: trainImageData) { result in
            guard let firstSimilarityMatrix = result?.first else {return}
            if let similarityIdx = firstSimilarityMatrix.similarity as? Double{
                if similarityIdx >= self.thresholdForRecognition {
                    simlarityCompleation(true)
                }else{
                    simlarityCompleation(false)
                }
            }
        }
    }
}
