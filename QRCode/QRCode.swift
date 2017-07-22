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
    
    class open func generateImage(_ stringValue: String, avatarImage: UIImage?, avatarScale: CGFloat = 0.25, color: CIColor, backColor: CIColor) -> UIImage? {
        
        // generate qrcode image
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
        qrFilter.setDefaults()
        qrFilter.setValue(stringValue.data(using: String.Encoding.utf8, allowLossyConversion: false), forKey: "inputMessage")
        
        let ciImage = qrFilter.outputImage
        
        // scale qrcode image
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(ciImage, forKey: "inputImage")
        colorFilter.setValue(color, forKey: "inputColor0")
        colorFilter.setValue(backColor, forKey: "inputColor1")
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let transformedImage = qrFilter.outputImage!.transformed(by: transform)
        
        let image = UIImage(ciImage: transformedImage)
        
        if avatarImage != nil {
            return insertAvatarImage(image, avatarImage: avatarImage!, scale: avatarScale)
        }
        
        return image
    }
    
    class func insertAvatarImage(_ codeImage: UIImage, avatarImage: UIImage, scale: CGFloat) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: codeImage.size.width, height: codeImage.size.height)
        UIGraphicsBeginImageContext(rect.size)
        
        codeImage.draw(in: rect)
        
        let avatarSize = CGSize(width: rect.size.width * scale, height: rect.size.height * scale)
        let x = (rect.width - avatarSize.width) * 0.5
        let y = (rect.height - avatarSize.height) * 0.5
        avatarImage.draw(in: CGRect(x: x, y: y, width: avatarSize.width, height: avatarSize.height))
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return result!
    }
    
}
