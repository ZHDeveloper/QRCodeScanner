//
//  ViewController.swift
//  QRCode
//
//  Created by ZhiHua Shen on 2017/7/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "二维码"
    }
    
    @IBAction func pickImageAction(_ sender: Any) {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        
        let pickVC = UIImagePickerController()
        pickVC.sourceType = .photoLibrary
        pickVC.delegate = self
        
        present(pickVC, animated: true, completion: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let results = QRCodeScanner.identifyQRCode(image)
        
        results.forEach {
            print($0)
        }
    }
    
}
