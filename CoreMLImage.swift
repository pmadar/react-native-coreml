import Foundation
import UIKit
import CoreML
import Vision

@available(iOS 11.0, *)
@objc(CoreMLImage)
public class CoreMLImage: UIView {

  var bridge: RCTEventDispatcher!
  var model: VNCoreMLModel?
  var image: UIImage?
  var lastClassification: String = ""
  var onClassification: RCTBubblingEventBlock?

  required public init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.frame = frame;
  }

  func runMachineLearning(img: UIImage) {
    let image = self.crop(image: img, withWidth: 224, andHeight: 224)
    let ciImage = CIImage(image: image!)
    if (self.model != nil) {
      let request = VNCoreMLRequest(model: self.model!, completionHandler: { [weak self] request, error in
        self?.processClassifications(for: request, error: error)
      })
      request.imageCropAndScaleOption = .centerCrop

      let orientation = CGImagePropertyOrientation.up

      DispatchQueue.global(qos: .userInitiated).async {
        let handler = VNImageRequestHandler(ciImage: ciImage!, orientation: orientation)
        do {
          try handler.perform([request])
        } catch {
          print("Failed to perform classification.\n\(error.localizedDescription)")
        }
      }
    }
  }

  func processClassifications(for request: VNRequest, error: Error?) {
    DispatchQueue.main.async {
      guard let results = request.results else {
        print("Unable to classify image")
        print(error!.localizedDescription)
        return
      }
      let imageMultiArray = (results[0] as AnyObject).featureValue.multiArrayValue
      var vector = [NSNumber]()
      for i in 0..<((imageMultiArray?.count)!) {
        vector.append(imageMultiArray![i])
      }
      self.onClassification!(["vector": vector])
    }
  }

  func crop(image: UIImage, withWidth width: Double, andHeight height: Double) -> UIImage? {
    if let cgImage = image.cgImage {
      let contextImage: UIImage = UIImage(cgImage: cgImage)
      let contextSize: CGSize = contextImage.size
      var posX: CGFloat = 0.0
      var posY: CGFloat = 0.0
      var cgwidth: CGFloat = CGFloat(width)
      var cgheight: CGFloat = CGFloat(height)

      if contextSize.width > contextSize.height {
        posX = ((contextSize.width - contextSize.height) / 2)
        posY = 0
        cgwidth = contextSize.height
        cgheight = contextSize.height
      } else {
        posX = 0
        posY = ((contextSize.height - contextSize.width) / 2)
        cgwidth = contextSize.width
        cgheight = contextSize.width
      }

      let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)

      var croppedContextImage: CGImage? = nil
      if let contextImage = contextImage.cgImage {
        if let croppedImage = contextImage.cropping(to: rect) {
          croppedContextImage = croppedImage
        }
      }

      if let croppedImage:CGImage = croppedContextImage {
        let image: UIImage = UIImage(cgImage: croppedImage, scale: image.scale, orientation: image.imageOrientation)
        return image
      }
    }
    return nil
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    runMachineLearning(img: self.image!)
  }

  @objc(setModelFile:) public func setModelFile(modelFile: String) {
    print("Setting model file to: " + modelFile)
    let path = Bundle.main.url(forResource: modelFile, withExtension: "mlmodelc")
    do {
      let modelUrl = try MLModel.compileModel(at: path!)
      let model = try MLModel.init(contentsOf: modelUrl)
      self.model = try VNCoreMLModel(for: model)
    } catch {
      print("Error")
    }

  }

  @objc(setImageFile:) public func setImageFile(imageFile: String) {
    print("Setting image file to: " + imageFile)
    self.image = UIImage(contentsOfFile: imageFile)
  }

  @objc(setOnClassification:) public func setOnClassification(onClassification: @escaping RCTBubblingEventBlock) {
    self.onClassification = onClassification
  }

}
