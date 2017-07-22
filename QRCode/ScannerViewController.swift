//
//  ScannerViewController.swift
//  QRCode
//
//  Created by ZhiHua Shen on 2017/7/22.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

import UIKit

class ScannerViewController: UIViewController {

    let scanner = QRCodeScanner()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scanner.view)
        scanner.view.fillToSuperview()
        
        do {
            try scanner.prepareSession()
        } catch  {
            print(error.localizedDescription)
        }
        
        scanner.setFetchHandler {[weak self] (result) in
            self?.title = result
        }
        
    }
    
}
