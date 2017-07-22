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
    
    public class func generateImage(_ content: String, targetSize: CGSize, maskImage: UIImage?, color: UIColor? = nil) -> UIImage? {
        
        let codeImage = generateImage(content, targetSize: targetSize, color: color)
        
        guard let maskImage = maskImage else { return codeImage}
        
        return codeImage?.insertMaskImage(maskImage)
    }
    
    public class func generateImage(_ content: String, targetSize: CGSize, color: UIColor? = nil) -> UIImage? {
        
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
        qrFilter.setDefaults()
        qrFilter.setValue(content.data(using: String.Encoding.utf8, allowLossyConversion: false), forKey: "inputMessage")
        
        guard let ciImage = qrFilter.outputImage else { return nil}
        
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(ciImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(color: color ?? UIColor.black), forKey: "inputColor0")
        colorFilter.setValue(CIColor(color: UIColor.white), forKey: "inputColor1")
        
        let transform = CGAffineTransform(scaleX: targetSize.width / ciImage.extent.width, y: targetSize.height / ciImage.extent.height)
        let transformedImage = qrFilter.outputImage!.transformed(by: transform)
        
        return UIImage(ciImage: transformedImage)
    }
    
}

fileprivate extension UIImage {
    
    func insertMaskImage(_ image: UIImage) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        
        draw(in: rect)
        
        let scale: CGFloat = 0.5
        
        let avatarSize = CGSize(width: rect.size.width * scale, height: rect.size.height * scale)
        let x = (rect.width - avatarSize.width) * 0.5
        let y = (rect.height - avatarSize.height) * 0.5
        
        image.draw(in: CGRect(x: x, y: y, width: avatarSize.width, height: avatarSize.height))
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return result!
    }
}
