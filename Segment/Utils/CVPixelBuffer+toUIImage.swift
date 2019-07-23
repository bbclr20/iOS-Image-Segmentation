//
//  CVPixelBuffer+toUIImage.swift
//
//  Created by ben on 2019/3/19.
//  Copyright © 2019 ben. All rights reserved.
//

import CoreVideo
import UIKit

extension CVPixelBuffer {
    
    /**
     Convert CVPixelBuffer to ARGB UIImage.
     Each channel in ARGB is represented by 8 bits.
     The videoSettings of output device must be "kCVPixelFormatType_32BGRA".
     
     - Returns: UIImage?
     */
    func toUIImage() -> UIImage? {
        do {
            CVPixelBufferLockBaseAddress(self, .readOnly)
            defer {
                CVPixelBufferUnlockBaseAddress(self, .readOnly)
            }
            
            let address = CVPixelBufferGetBaseAddressOfPlane(self, 0)
            let width = CVPixelBufferGetWidth(self)
            let height = CVPixelBufferGetHeight(self)
            
            // ARGB 8 bits per component
            let bits = 8
            let bytes = CVPixelBufferGetBytesPerRow(self)
            let info = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
            let color = CGColorSpaceCreateDeviceRGB()
            
            guard let context = CGContext(data: address,
                                          width: width,
                                          height: height,
                                          bitsPerComponent: bits,
                                          bytesPerRow: bytes,
                                          space: color,
                                          bitmapInfo: info) else {
                print("Fail to create CGContext")
                return nil
            }
            
            guard let image = context.makeImage() else {
                print("Fail to create CGImage")
                return nil
            }
            
            let captureImage = UIImage(cgImage: image)
            return captureImage
        }
    }
}
