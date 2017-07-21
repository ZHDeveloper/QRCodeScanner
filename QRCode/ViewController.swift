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

    let scanner = ZHScanner()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scanner.view)
        scanner.view.fillToSuperview()
        
        try? scanner.prepareSession()
    }
    
}

