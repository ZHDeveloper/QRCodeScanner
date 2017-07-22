//
//  QRCodeGenerateViewController.swift
//  QRCode
//
//  Created by ZhiHua Shen on 2017/7/22.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

import UIKit

class GenerateViewController: UIViewController {
    
    @IBOutlet weak var codeView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(GenerateViewController.saveToAlbumAction))
        navigationItem.rightBarButtonItem = rightItem
        
//        codeView.image = QRCodeGenerator.generateImage("https://github.com/ZHDeveloper", targetSize: CGSize(width: 250, height: 250))
//        codeView.image = QRCodeGenerator.generateImage("https://github.com/ZHDeveloper", targetSize: CGSize(width: 250, height: 250), color: .red)
//        codeView.image = QRCodeGenerator.generateImage("https://github.com/ZHDeveloper", targetSize: CGSize(width: 250, height: 250), maskImage: #imageLiteral(resourceName: "avart"))
        codeView.image = QRCodeGenerator.generateImage("https://github.com/ZHDeveloper", targetSize: CGSize(width: 250, height: 250), maskImage: #imageLiteral(resourceName: "avart"), color: .gray)
        
    }

    @IBAction func generateAction(_ sender: Any) {
        
    }
    
    @objc func saveToAlbumAction() {
        guard let image = codeView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
