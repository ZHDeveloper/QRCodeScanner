//
//  QRCodeGenerateViewController.swift
//  QRCode
//
//  Created by ZhiHua Shen on 2017/7/22.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

import UIKit

class QRCodeGenerateViewController: UIViewController {
    
    @IBOutlet weak var codeView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        codeView.image = QRCodeGenerator.generateImage("https://github.com/ZHDeveloper", targetSize: CGSize(width: 100, height: 100))
//        codeView.image = QRCodeGenerator.generateImage("https://github.com/ZHDeveloper", targetSize: CGSize(width: 100, height: 100), color: .gray)
//        codeView.image = QRCodeGenerator.generateImage("https://github.com/ZHDeveloper", targetSize: CGSize(width: 100, height: 100), maskImage: #imageLiteral(resourceName: "avart"))
        codeView.image = QRCodeGenerator.generateImage("https://github.com/ZHDeveloper", targetSize: CGSize(width: 100, height: 100), maskImage: #imageLiteral(resourceName: "avart"), color: .gray)
        
        print(codeView.image?.size)
    }

}
