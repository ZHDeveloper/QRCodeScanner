## QRCodeScanner
QRCodeScanner是二维码扫描相关的类，但不提供扫描界面场景，建议根据需求效果图进行添加。QRCodeScannerView则是默认提供的一套UI界面View。

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


## QRCodeGenerator
QRCodeGenerator是二维码生成类。

```
codeView.image = QRCodeGenerator.generateImage("https://github.com/ZHDeveloper", targetSize: CGSize(width: 250, height: 250))
codeView.image = QRCodeGenerator.generateImage("https://github.com/ZHDeveloper", targetSize: CGSize(width: 250, height: 250), color: .red)
codeView.image = QRCodeGenerator.generateImage("https://github.com/ZHDeveloper", targetSize: CGSize(width: 250, height: 250), maskImage: #imageLiteral(resourceName: "avart"))
codeView.image = QRCodeGenerator.generateImage("https://github.com/ZHDeveloper", targetSize: CGSize(width: 250, height: 250), maskImage: #imageLiteral(resourceName: "avart"), color: .gray)

```