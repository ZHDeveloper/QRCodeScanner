//
//  ZHScanner.swift
//  QRCode
//
//  Created by ZhiHua Shen on 2017/7/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

import UIKit
import AVFoundation

public enum ScannerError: Error,LocalizedError {
    case cameraAuthorDenied
    case addDeviceInputFail
    case addDataOutputFail
    
    public var errorDescription: String? {
        switch self {
        case .cameraAuthorDenied:
            return "Camera use not allow!!!"
        case .addDeviceInputFail:
            return "Can not add input device!!!"
        case .addDataOutputFail:
            return "Can not add video data output!!!"
        }
    }
}

public class QRCodeScanner: NSObject {
    
    public let view = QRCodePreviewView(frame: CGRect.zero)
    
    public let session = AVCaptureSession()
    
    private let deviceInput: AVCaptureDeviceInput? = {
        guard let device = AVCaptureDevice.default(for: .video) else { return nil}
        let input = try? AVCaptureDeviceInput(device: device)
        return input
    }()
    
    private let dataOutput: AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    
    fileprivate var fetchHandler: ((String)->())?
    
    public func prepareSession() throws {
        
        if session.isRunning { return }
        
        guard AVCaptureDevice.authorizationStatus(for: .video) != .denied else {
            throw ScannerError.cameraAuthorDenied
        }
        
        guard let deviceInput = deviceInput, session.canAddInput(deviceInput) else {
            throw ScannerError.addDeviceInputFail
        }
        
        guard session.canAddOutput(dataOutput)  else {
            throw ScannerError.addDataOutputFail
        }
        
        session.addInput(deviceInput)
        session.addOutput(dataOutput)
        
        dataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        dataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        view.previewLayer.session = session
        session.startRunning()
    }
    
    public func stopSession() {
        session.stopRunning()
    }
    
    public func setFetchHandler(_ handler: ((String)->())?) {
        self.fetchHandler = handler
    }
    
    public func toggleFlash() throws {
        
        if !session.isRunning { return }

        guard let device = deviceInput?.device else { return }
        
        do {
            try device.lockForConfiguration()
        } catch  {
            throw error
        }
        if device.flashMode == .on {
            if device.isFlashModeSupported(.off),device.isTorchModeSupported(.off) {
                device.flashMode = .off
                device.torchMode = .off
            }
        }
        else if device.flashMode == .off {
            if device.isFlashModeSupported(.on),device.isTorchModeSupported(.on) {
                device.flashMode = .on
                device.torchMode = .on
            }
        }
        device.unlockForConfiguration()
    }

    
    deinit {
        dataOutput.setMetadataObjectsDelegate(nil, queue: DispatchQueue.main)
        session.stopRunning()
        view.removeFromSuperview()
        print("QRCodeScanner has deinit!!!")
    }
}

extension QRCodeScanner: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        for dataObject in metadataObjects {
            if let obj = dataObject as? AVMetadataMachineReadableCodeObject,let result = obj.stringValue {
                fetchHandler?(result)
                break
            }
        }
    }
    
}

public class QRCodePreviewView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        
        previewLayer.videoGravity = .resizeAspectFill
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public class var layerClass: AnyClass {
        get {
            return AVCaptureVideoPreviewLayer.self
        }
    }
    
    public var previewLayer: AVCaptureVideoPreviewLayer {
        get {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
}

public class QRCodeGenerator: NSObject {
    
    public class func generateImage(_ content: String, targetSize: CGSize, maskImage: UIImage?, color: UIColor = .black) -> UIImage? {
        
        let codeImage = generateImage(content, targetSize: targetSize, color: color)
        
        guard let maskImage = maskImage?.byRoundCornerRadius(10/0.2, borderWidth: 6/0.2) else { return codeImage}
        
        UIImageWriteToSavedPhotosAlbum(maskImage, nil, nil, nil)
        
        return codeImage?.insertMaskImage(maskImage)
    }
    
    public class func generateImage(_ content: String, targetSize: CGSize, color: UIColor = .black) -> UIImage? {
        
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
        qrFilter.setDefaults()
        qrFilter.setValue(content.data(using: String.Encoding.utf8, allowLossyConversion: false), forKey: "inputMessage")
        
        guard let ciImage = qrFilter.outputImage,let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
        
        colorFilter.setDefaults()
        colorFilter.setValue(ciImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(color: color), forKey: "inputColor0")
        colorFilter.setValue(CIColor(color: .white), forKey: "inputColor1")
        
        guard let outImage = colorFilter.outputImage  else { return nil }
        
        let scaleX = targetSize.width / outImage.extent.width;
        let scaleY = targetSize.height / outImage.extent.height
        
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        
        let transformImage = outImage.transformed(by: transform)

        return UIImage(ciImage: transformImage)
    }
    
}

fileprivate extension UIImage {
    
    func insertMaskImage(_ image: UIImage) -> UIImage? {
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)

        defer {
            UIGraphicsEndImageContext()
        }
        
        draw(in: rect)
        
        let maskSize = CGSize(width: size.width * 0.2, height: rect.size.height * 0.2)
        let x = (rect.width - maskSize.width) * 0.5
        let y = (rect.height - maskSize.height) * 0.5
        
        image.draw(in: CGRect(x: x, y: y, width: maskSize.width, height: maskSize.height))

        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func byRoundCornerRadius(_ radius: CGFloat, borderWidth: CGFloat = 0, borderColor: UIColor = .white) -> UIImage? {
        
        let imageView = UIImageView(image: self)
        imageView.layer.cornerRadius = radius
        imageView.layer.borderWidth = borderWidth
        imageView.layer.borderColor = borderColor.cgColor
        imageView.layer.masksToBounds = true
        imageView.layer.allowsEdgeAntialiasing = true
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale);
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        imageView.layer.render(in: context)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }

}
