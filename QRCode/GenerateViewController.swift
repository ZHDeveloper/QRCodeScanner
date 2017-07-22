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
        
//        codeView.image = QRCodeGenerator.generateImage("https://github.com/ZHDeveloper", targetSize: CGSize(width: 250, height: 250))
//        codeView.image = QRCodeGenerator.generateImage("https://github.com/ZHDeveloper", targetSize: CGSize(width: 250, height: 250), color: .red)
//        codeView.image = QRCodeGenerator.generateImage("https://github.com/ZHDeveloper", targetSize: CGSize(width: 250, height: 250), maskImage: #imageLiteral(resourceName: "avart"))
        codeView.image = QRCodeGenerator.generateImage("https://github.com/ZHDeveloper", targetSize: CGSize(width: 250, height: 250), maskImage: #imageLiteral(resourceName: "avart"), color: .gray)
        
    }

}
