//
//  ViewController.swift
//  图片加载优化
//
//  Created by 沈春兴 on 2023/8/12.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    override func viewDidLoad() {
           super.viewDidLoad()

        
        //1.子线程操作
           DispatchQueue.global().async {
               //4.不要用`JPEG`的图片，应当使用`PNG`图片
               if let image = UIImage(named: "icon_cancel") {
                   let decodedImage = self.decodeImage(image)

                   DispatchQueue.main.async {
                       //如果不提前解码图片，主线程这里赋值会自动解码图片，需要消耗性能
                       //如果不提前解码，就需要动态缩放了。缩放到imageview的大小。这样可以减少图片显示时的处理计算。
                       self.imageView.image = decodedImage
                   }
               }
           }
       }

     //2.提前解码图片，获得位图
       func decodeImage(_ image: UIImage) -> UIImage {
           guard let cgImage = image.cgImage else {
               return image
           }

           let colorSpace = CGColorSpaceCreateDeviceRGB()
           let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
           guard let context = CGContext(data: nil, width: cgImage.width, height: cgImage.height,
                                         bitsPerComponent: 8, bytesPerRow: 0,
                                         space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
               return image
           }

           context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))

           //3.得到解码后的图片并直接赋值给了imageView。保证了尺寸是一致的。因此不需要继续计算和裁剪尺寸了
           if let decodedImage = context.makeImage() {
               return UIImage(cgImage: decodedImage)
           } else {
               return image
           }
       }

    //5.尽可能将多张图片合成为一张进行显示。
    //6.适配不同机型图片：@1x，@2x，@3x

}

//4.动态缩放（如果不在子线程提前解码，就用该方案，该方案可以在给imageView赋值image的时候减少图片显示时的处理计算。在子线程提前解码是更好的方案）
extension UIImage {
    func resized(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}

