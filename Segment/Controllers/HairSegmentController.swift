//
//  HairSegmentController.swift
//  Segment
//
//  Created by ben on 2019/7/17.
//  Copyright © 2019 ben. All rights reserved.
//

import UIKit
import Vision

class HairSegmentController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var imagePicker = UIImagePickerController()
    lazy var request = hairSegmentRequest(model: Hair().model)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFit
    }
    
    @IBAction func selectImage() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true)
        } else {
            print("Photo library is not available")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
   
    // MARK: - fuctions relative to CoreML
    
    /**
     Create a hair segmentation request.
     
     - Parameters:
     model: MLModel: deep learning model.
     
     - Returns: VNCoreMLRequest
     */
    func hairSegmentRequest(model: MLModel)->VNCoreMLRequest {
        do {
            let model = try VNCoreMLModel(for: model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: {
                [weak self] request, error in
                self?.updateSegmentedImage(for: request, error: error)
            })
            // MARK: - scale input with vision
            request.imageCropAndScaleOption = .scaleFill
            return request
        } catch {
            fatalError("Fail to load ML model: \(error)")
        }
    }
    
    /**
     A hook to process the result returned by request.
     
     - Parameters:
     for: VNRequest:
     error: Error?:
     */
    func updateSegmentedImage(for request:VNRequest, error: Error?) {
        guard let result = request.results else {
            return
        }
        
        let segmentResult = result as! [VNPixelBufferObservation]
        
        
        if segmentResult.isEmpty {
            print("Request return empty observation")
        } else {
            let buffer = segmentResult.last?.pixelBuffer
            guard let segmentedMaskImage = buffer?.toUIImage() else { return }
            DispatchQueue.main.async {
                guard let input = self.imageView.image else {
                    print("Image not available")
                    return
                }
                self.imageView.image = segmentedMaskImage.resize(to: input.size)
            }
        }
    }
    
    
    /**
     Wrap the CVPixelBuffer and perform the request.

     - Parameters:
     buffer cvPixelBuffer: CVPixelBuffer: input image.
     */
    func segmentSeq(buffer cvPixelBuffer: CVPixelBuffer) {
        let handler = VNSequenceRequestHandler()
        do {
            try handler.perform([self.request],
                                on: cvPixelBuffer,
                                orientation: .up)
        } catch {
            print("Fail to perform segment: \(error.localizedDescription)")
        }
    }

    @IBAction func hairSegment(_ sender: Any) {
        guard let buffer = imageView.image?.pixelBuffer() else {
            return
        }
        segmentSeq(buffer: buffer)
        
    }
}

// MARK: - UIImagePickerControllerDelegate

extension HairSegmentController: UIImagePickerControllerDelegate,
                                 UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            self.imageView.image = pickedImage
            self.imageView.backgroundColor = .clear
        }
        self.dismiss(animated: true)
    }
}
