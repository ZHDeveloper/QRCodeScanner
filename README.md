## QRCodeScanner
QRCodeScanner是二维码扫描相关的类，但不提供扫描界面场景，建议根据需求效果图进行添加。使用过程中需要强引用，避免对象提前释放。
当对象释放时，会停止session，并且将预览图层从父视图中移除。

此类提供的功能：

* 开启摄像头进行扫描
* 对UIImage进行二维码识别

```
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
```

## QRCodeScannerView
QRCodeScannerView则是默认提供的一套UI界面View。实际开发中还是要按照美工给的效果来实现。

```
let scannerView = QRCodeScannerView(frame: .zero)
...
view.addSubview(scannerView)
scannerView.fillToSuperview()

...
scannerView.startAnimation()

```

## QRCodeGenerator
QRCodeGenerator是二维码生成类。

特性：

* 自定义二维码内容
* 二维码颜色
* 添加个性头像

```
codeView.image = QRCodeGenerator.generateImage("https://github.com/ZHDeveloper", targetSize: CGSize(width: 250, height: 250))
codeView.image = QRCodeGenerator.generateImage("https://github.com/ZHDeveloper", targetSize: CGSize(width: 250, height: 250), color: .red)
codeView.image = QRCodeGenerator.generateImage("https://github.com/ZHDeveloper", targetSize: CGSize(width: 250, height: 250), maskImage: #imageLiteral(resourceName: "avart"))
codeView.image = QRCodeGenerator.generateImage("https://github.com/ZHDeveloper", targetSize: CGSize(width: 250, height: 250), maskImage: #imageLiteral(resourceName: "avart"), color: .gray)

```

## 效果图

![效果图](./WechatIMG9.jpeg)