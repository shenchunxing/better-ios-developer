//
//  ViewController.swift
//  图片和视图的显示优化
//
//  Created by 沈春兴 on 2023/8/12.
//

import UIKit

class CustomDrawingView: UIView {

    //1.draw（适合静态绘制）,该绘制会覆盖掉默认的一些设置，比如背景色，需要重新设置
    override func draw(_ rect: CGRect) {
        DispatchQueue.global().async {
            let image = self.drawImage(rect)
            DispatchQueue.main.async {
                //绘制号好显示到layer上
                self.layer.contents = image.cgImage
            }
        }
    }

    //2。子线程绘制图形
    func drawImage(_ rect: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }

        // Perform drawing operations
        context.setStrokeColor(UIColor.blue.cgColor)
        context.setLineWidth(2.0)
        context.addRect(rect)
        context.drawPath(using: .stroke)

        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var customView: CustomDrawingView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Trigger a manual refresh of the custom view
        //3.延迟绘制只在需要更新视图时才调用setNeedsDisplay()方法来触发重绘，而不是在每一帧都调用。可以在数据更新后、布局改变后等时机触发重绘。
        customView.setNeedsDisplay()
    }
}

