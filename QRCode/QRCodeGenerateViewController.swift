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
        
//        codeView.image = QRCodeGenerator.generateImage("www.baidu.com", targetSize: CGSize(width: 100, height: 100))
        
//        codeView.image = QRCodeGenerator.generateImage("www.baidu.com", targetSize: CGSize(width: 200, height: 200), maskImage: #imageLiteral(resourceName: "avart"))
        
        codeView.image = QRCodeGenerator.generateImage("www.baidu.com", targetSize: CGSize(width: 200, height: 200))
    }

}
