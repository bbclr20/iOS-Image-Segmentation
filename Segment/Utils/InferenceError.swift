//
//  InferenceError.swift
//
//  Created by ben on 2019/3/19.
//  Copyright © 2019 ben. All rights reserved.
//

import Foundation

public enum InferenceError : Error {
    case unknown
    case resizeError
    case pixelBufferError
    case predictionError
}

extension InferenceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .resizeError:
            return "Resizing failed"
        case .pixelBufferError:
            return "Pixel Buffer conversion failed"
        case .predictionError:
            return "CoreML prediction failed"
        }
    }
}
