//
//  DownsamplingImageProcessor.swift
//  KingfisherBestPractice
//
//  Created by wuweixin on 2019/11/22.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import Kingfisher

/// Processor for downsampling an image. Compared to `ResizingImageProcessor`, this processor
/// does not render the images to resize. Instead, it downsample the input data directly to an
/// image. It is a more efficient than `ResizingImageProcessor`.
///
/// Only CG-based images are supported. Animated images (like GIF) is not supported.
public struct DownsamplingImageProcessor: ImageProcessor {
    
    /// Target size of output image should be. It should be smaller than the size of
    /// input image. If it is larger, the result image will be the same size of input
    /// data without downsampling.
    public let size: CGSize
    
    /// Identifier of the processor.
    /// - Note: See documentation of `ImageProcessor` protocol for more.
    public let identifier: String
    
    /// Creates a `DownsamplingImageProcessor`.
    ///
    /// - Parameter size: The target size of the downsample operation.
    public init(size: CGSize) {
        self.size = size
        self.identifier = "com.onevcat.Kingfisher.DownsamplingImageProcessor(\(size))"
    }
    
    /// Processes the input `ImageProcessItem` with this processor.
    ///
    /// - Parameters:
    ///   - item: Input item which will be processed by `self`.
    ///   - options: Options when processing the item.
    /// - Returns: The processed image.
    ///
    /// - Note: See documentation of `ImageProcessor` protocol for more.
    public func process(item: ImageProcessItem, options: KingfisherOptionsInfo) -> Image? {
        switch item {
        case .image(let image):
            guard let data = image.kf.data(format: .unknown) else {
                return nil
            }
            return Kingfisher.downsampledImage(data: data, to: size, scale: options.scaleFactor)
        case .data(let data):
            return Kingfisher.downsampledImage(data: data, to: size, scale: options.scaleFactor)
        }
    }
}

extension Kingfisher where Base: Image {
    /// Returns a data representation for `base` image, with the `format` as the format indicator.
    ///
    /// - Parameter format: The format in which the output data should be. If `unknown`, the `base` image will be
    ///                     converted in the PNG representation.
    /// - Returns: The output data representing.
    public func data(format: ImageFormat) -> Data? {
        return autoreleasepool { () -> Data? in
            let data: Data?
            switch format {
            case .PNG: data = pngRepresentation()
            case .JPEG: data = jpegRepresentation(compressionQuality: 1.0)
            case .GIF: data = gifRepresentation()
            case .unknown: data = normalized.kf.pngRepresentation()
            }
            
            return data
        }
    }
    
    /// Creates a downsampled image from given data to a certain size and scale.
    ///
    /// - Parameters:
    ///   - data: The image data contains a JPEG or PNG image.
    ///   - pointSize: The target size in point to which the image should be downsampled.
    ///   - scale: The scale of result image.
    /// - Returns: A downsampled `Image` object following the input conditions.
    ///
    /// - Note:
    /// Different from image `resize` methods, downsampling will not render the original
    /// input image in pixel format. It does downsampling from the image data, so it is much
    /// more memory efficient and friendly. Choose to use downsampling as possible as you can.
    ///
    /// The input size should be smaller than the size of input image. If it is larger than the
    /// original image size, the result image will be the same size of input without downsampling.
    public static func downsampledImage(data: Data, to pointSize: CGSize, scale: CGFloat) -> Image? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            return nil
        }
        
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }
        return Kingfisher.image(cgImage: downsampledImage, scale: scale, refImage: nil)
    }
    
    static func image(cgImage: CGImage, scale: CGFloat, refImage: Image?) -> Image {
        return Image(cgImage: cgImage, scale: scale, orientation: refImage?.imageOrientation ?? .up)
    }
}

