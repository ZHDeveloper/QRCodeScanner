//
//  QRCodeScannerView.swift
//  QRCode
//
//  Created by ZhiHua Shen on 2017/7/22.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

import UIKit

public class QRCodeScannerView: UIView {
    
    private let contentView = UIView()
    
    private let scanBorder = UIImageView()
    
    private let scanLine = UIImageView()
    
    private let mainMaskView = UIView()
    
    private var linebottomConst: NSLayoutConstraint!
    
    private var isAnimation: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = true
        
        addSubview(contentView)
        contentView.anchorCenterSuperview()
        contentView.anchor(widthConstant: 200, heightConstant: 200)
        
        let image = UIImage(named: "QRCode.bundle/qrcode_border")!
        
        scanBorder.image = image.stretchableImage(withLeftCapWidth: Int(image.size.width * 0.5), topCapHeight: Int(image.size.width * 0.5))
        contentView.addSubview(scanBorder)
        scanBorder.fillToSuperview()
        
        scanLine.image = UIImage(named: "QRCode.bundle/qrcode_scanline")
        contentView.addSubview(scanLine)
        scanLine.anchor(left: contentView.leftAnchor, right: contentView.rightAnchor, leftConstant: 4, rightConstant: 4)
        
        linebottomConst = scanLine.bottomAnchor.constraint(equalTo: contentView.topAnchor, constant: 0)
        linebottomConst.isActive = true

        mainMaskView.backgroundColor = UIColor.black
        mainMaskView.alpha = 0.4
        
        addSubview(mainMaskView)
        mainMaskView.fillToSuperview()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
    }
    
    public func startAnimation() {
        
        removeAnimation()
        
        isAnimation = true
        
        UIView.animate(withDuration: 2.0) {
            UIView.setAnimationRepeatCount(HUGE)
            self.linebottomConst.constant = 350
            self.layoutIfNeeded()
        }
        
    }
    
    public func removeAnimation() {
        
        scanLine.layer.removeAllAnimations()
        
        linebottomConst.constant = 0
        layoutIfNeeded()
        
        isAnimation = false
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = UIBezierPath()
        path.append(UIBezierPath(rect: mainMaskView.bounds))
        
        let margin: CGFloat = 5
        let x = contentView.frame.minX + margin
        let y = contentView.frame.minY + margin
        let w = contentView.frame.width - margin * 2
        let h = contentView.frame.height - margin * 2
        
        let frame = CGRect(x: x, y: y, width: w, height: h)
        
        path.append(UIBezierPath(rect: frame).reversing())
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        
        mainMaskView.layer.mask = maskLayer
    }
    
    @objc private func applicationDidBecomeActive(_ noti: Notification) {
        
        guard isAnimation else { return }
        
        startAnimation()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
