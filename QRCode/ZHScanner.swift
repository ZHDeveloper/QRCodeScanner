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
    case addDeviceInput
    case addDataOutput
    
    public var errorDescription: String? {
        switch self {
        case .addDeviceInput:
            return "Can not add input device!"
        case .addDataOutput:
            return "Can not add video data output!"
        }
    }
}

public class ZHScanner: NSObject {
    
    public let view = ZHScannerView(frame: CGRect.zero)
    
    public let session = AVCaptureSession()
    
    private let deviceInput: AVCaptureDeviceInput? = {
        guard let device = AVCaptureDevice.default(for: .video) else { return nil}
        let input = try? AVCaptureDeviceInput(device: device)
        return input
    }()
    
    private let dataOutput: AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    
    public func prepareSession() throws {
        
        if session.isRunning { return }
        
        guard let deviceInput = deviceInput, session.canAddInput(deviceInput) else {
            throw ScannerError.addDeviceInput
        }
        
        guard session.canAddOutput(dataOutput)  else {
            throw ScannerError.addDataOutput
        }
        
        session.addInput(deviceInput)
        session.addOutput(dataOutput)
        
        dataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        dataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        view.previewLayer.session = session
        session.startRunning()
    }
    
    func startScan() {
        
    }
    
    deinit {
        session.stopRunning()
        view.removeFromSuperview()
    }
}

extension ZHScanner: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        for dataObject in metadataObjects {
            let obj = dataObject as? AVMetadataMachineReadableCodeObject
            print(obj?.stringValue)
        }
        
    }
    
}

public class ZHScannerView: UIView {
    
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


