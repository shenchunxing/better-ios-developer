//
//  ViewController.swift
//  UIView相关优化
//
//  Created by 沈春兴 on 2023/8/12.
//

import UIKit

class ViewController: UIViewController {
    
    var cachedSubviews: [UIView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
      
        useCALayerInsteadOfUIView()
        optimizeViewPropertyAccess()
        optimizeAutolayout()
        cacheAndToggleSubviews()
        useLayerForDrawing()
        reduceRedundantDrawing()
    }
    
    //1.使用轻量级的对象（CALayer替代UIView)
    func useCALayerInsteadOfUIView() {
        // 不好的写法：使用重量级的 UIView
        let heavyView = UIView(frame: CGRect(x: 50, y: 50, width: 100, height: 100))
        heavyView.backgroundColor = UIColor.blue
        view.addSubview(heavyView)
        
        // 优化后的写法：使用轻量级的 CALayer
        let lightweightLayer = CALayer()
        lightweightLayer.frame = CGRect(x: 50, y: 200, width: 100, height: 100)
        lightweightLayer.backgroundColor = UIColor.blue.cgColor
        view.layer.addSublayer(lightweightLayer)
        /*
         * 不好的写法解释：
         * UIView 除了呈现内容外，还负责事件处理、布局、视图层级管理等功能，因此比较重量级。
         * 这会导致在高性能场景下可能产生额外的开销。
         *
         * 优化后的写法解释：
         * CALayer 只用于呈现内容，不处理事件和布局，因此更轻量级。
         * 在不需要处理事件等额外功能的情况下，使用 CALayer 可以降低资源开销。
         */
    }

    //2.避免频繁调用和调整属性
    func optimizeViewPropertyAccess() {
        // 不好的写法：频繁修改属性
        let movingView = UIView(frame: CGRect(x: 50, y: 200, width: 100, height: 100))
        movingView.backgroundColor = UIColor.green
        view.addSubview(movingView)
        
        UIView.animate(withDuration: 1.0, animations: {
            // 频繁修改属性会产生多次的属性调用和布局计算，影响性能。
            movingView.frame.origin.x += 100
            movingView.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 1.0, animations: {
                // 频繁修改属性会导致动画不流畅和性能问题。
                movingView.frame.origin.x -= 100
                movingView.alpha = 1.0
            })
        }
        
        // 优化后的写法：避免频繁修改属性
        let optimizedView = UIView(frame: CGRect(x: 50, y: 350, width: 100, height: 100))
        optimizedView.backgroundColor = UIColor.green
        view.addSubview(optimizedView)
        
        UIView.animate(withDuration: 1.0, animations: {
            // 在动画开始前一次性设置目标状态，避免频繁属性修改和布局计算。
            let translation = CGAffineTransform(translationX: 100, y: 0)
            optimizedView.transform = translation
            optimizedView.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 1.0, animations: {
                // 在动画结束后重置属性，保持动画的流畅性。
                optimizedView.transform = .identity
                optimizedView.alpha = 1.0
            })
        }
    }

    //3.Autolayout相对于Frame的资源消耗
    func optimizeAutolayout() {
        // 不好的写法：使用 Autolayout 创建子视图
        let autolayoutContainer = UIView()
        autolayoutContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(autolayoutContainer)
        
        NSLayoutConstraint.activate([
            autolayoutContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            autolayoutContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        for _ in 0..<10 {
            let subview = UIView()
            subview.backgroundColor = UIColor.random()
            subview.translatesAutoresizingMaskIntoConstraints = false
            autolayoutContainer.addSubview(subview)
            
            NSLayoutConstraint.activate([
                subview.widthAnchor.constraint(equalToConstant: 100),
                subview.heightAnchor.constraint(equalToConstant: 100)
            ])
        }
        
        // 优化后的写法：使用 Frame 创建子视图
        let frameContainer = UIView(frame: CGRect(x: 0, y: 500, width: view.bounds.width, height: 200))
        frameContainer.backgroundColor = UIColor.lightGray
        view.addSubview(frameContainer)
        
        var xOffset: CGFloat = 0
        for _ in 0..<10 {
            let subview = UIView(frame: CGRect(x: xOffset, y: 0, width: 100, height: 100))
            subview.backgroundColor = UIColor.random()
            frameContainer.addSubview(subview)
            xOffset += 100
        }
        /*
         * 不好的写法解释：
         * 使用 Autolayout 创建子视图时，布局计算复杂，当视图数量增加时，性能会呈指数级增长。
         * 这可能导致当视图数量增加时，使用 Autolayout 进行布局计算可能导致性能下降和卡顿。
         
         优化后的写法解释：
         使用 Frame 进行布局计算相对轻量级，不涉及复杂的 Autolayout 计算。在简单的场景中，使用 Frame 创建子视图可以显著提高性能。
         */
        }
    
    // 4.缓存 subviews 并善用 hidden，以避免频繁创建和销毁视图
        func cacheAndToggleSubviews() {
            for index in 0..<5 {
                let subview = UIView(frame: CGRect(x: 50 * index, y: 100, width: 40, height: 40))
                subview.backgroundColor = UIColor.random()
                view.addSubview(subview)
                cachedSubviews.append(subview) // 缓存 subviews

                // 初始状态显示一半的视图，随后点击按钮切换显示状态
                if index % 2 == 0 {
                    subview.isHidden = true
                }
            }

            let toggleButton = UIButton(frame: CGRect(x: 150, y: 200, width: 100, height: 40))
            toggleButton.setTitle("Toggle", for: .normal)
            toggleButton.setTitleColor(.blue, for: .normal)
            toggleButton.addTarget(self, action: #selector(toggleSubviewsVisibility), for: .touchUpInside)
            view.addSubview(toggleButton)
        }

        @objc func toggleSubviewsVisibility() {
            for subview in cachedSubviews {
                subview.isHidden.toggle() // 切换 subviews 的显示状态
            }
        }
    
    // 5.使用 layer 绘制元素来减少视图层级
       func useLayerForDrawing() {
           let parentLayer = CALayer()
           parentLayer.frame = CGRect(x: 50, y: 300, width: 300, height: 100)
           parentLayer.backgroundColor = UIColor.lightGray.cgColor
           view.layer.addSublayer(parentLayer)

           let subLayer = CALayer()
           subLayer.frame = CGRect(x: 80, y:80,width:100,height: 80)
           subLayer.backgroundColor = UIColor.blue.cgColor
           subLayer.cornerRadius = 40
           parentLayer.addSublayer(subLayer)
           /*
            * 使用 CALayer 进行绘制可以减少视图层级，提高性能。
            * 在这个示例中，parentLayer 包含一个 subLayer，而不是使用多个 UIView 来实现。
            */
       }
    
    // 6.减少不必要的绘制操作，避免过多重绘
        func reduceRedundantDrawing() {
            let drawingView = UIView(frame: CGRect(x: 50, y: 450, width: 200, height: 100))
            drawingView.backgroundColor = .white
            view.addSubview(drawingView)

            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = drawingView.bounds
            shapeLayer.fillColor = UIColor.green.cgColor
            shapeLayer.path = UIBezierPath(rect: drawingView.bounds).cgPath
            drawingView.layer.addSublayer(shapeLayer)
            
            // 添加一个按钮以触发重绘
            let drawButton = UIButton(frame: CGRect(x: 50,y:580, width: 100, height: 40))
            drawButton.setTitle("Redraw", for: .normal)
            drawButton.setTitleColor(.blue, for: .normal)
            drawButton.addTarget(self, action: #selector(redrawShapeLayer), for: .touchUpInside)
            view.addSubview(drawButton)
        }

        @objc func redrawShapeLayer() {
            // 避免在不必要的情况下进行重绘
            // 此示例中点击按钮后进行重绘，但在实际开发中应根据需要进行重绘操作。
            view.subviews.compactMap { $0 as? UIView }.forEach { view in
                view.setNeedsDisplay()
            }
        }
    
    
    //MARK:为啥`blending`会导致性能的损失？
    //原因是很直观的，如果一个图层是不透明的，则系统直接显示该图层的颜色即可。而如果图层是透明的，则会引起更多的计算，因为需要把另一个的图层也包括进来，进行混合后的颜色计算。
   //`opaque`设置为YES，减少性能消耗，因为GPU将不会做任何合成，而是简单从这个层拷贝。
    
    // 7.使用 alpha 小于 1 的视图会导致 Blending
        func avoidBlendingWithAlpha() {
            let alphaView = UIView(frame: CGRect(x: 50, y: 100, width: 100, height: 100))
            alphaView.backgroundColor = UIColor.red
            alphaView.alpha = 0.5 // 设置 alpha 小于 1
            view.addSubview(alphaView)
            /*
             * 设置 alpha 小于 1 的 UIView 会触发 Blending 计算，
             * 这会影响性能。在需要使用 alpha 的情况下，尽量将 alpha 值设置为 1，
             * 或者考虑使用 CALayer 来代替 UIView。
             */
        }

        // 8.使用带有 alpha 通道的图片会导致 Blending
        func avoidBlendingWithAlphaChannel() {
            let imageView = UIImageView(frame: CGRect(x: 50, y: 250, width: 100, height: 100))
            imageView.image = UIImage(named: "transparent_image.png") // 假设图片带有透明通道
            imageView.alpha = 1.0 // 由于 image 含有透明通道，仍然会触发 Blending
            view.addSubview(imageView)
            /*
             * 即使 UIImageView 的 alpha 设置为 1，只要其 image 含有透明通道，
             * 仍会导致 Blending 计算。在使用带有透明通道的图片时，
             * 尽量避免使用 alpha 通道或考虑优化图片资源。
             */
        }
    
    // 9.使用 opaque 属性减少性能消耗.因为GPU将不会做任何合成，而是简单从这个层拷贝
    func reducePerformanceConsumptionWithOpaque() {
           let opaqueView = UIView(frame: CGRect(x: 50, y: 100, width: 100, height: 100))
           opaqueView.backgroundColor = UIColor.red
           opaqueView.isOpaque = true // 设置 opaque 为 true
           view.addSubview(opaqueView)
           /*
            * 设置 UIView 的 isOpaque 属性为 true，告诉系统该视图完全不透明，
            * 这将减少 GPU 合成操作，直接从层拷贝，提高性能。
            * 请确保视图确实是不透明的，否则可能出现不正确的渲染效果。
            */
       }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: CGFloat.random(in: 0...1),
                       green: CGFloat.random(in: 0...1),
                       blue: CGFloat.random(in: 0...1),
                       alpha: 1.0)
    }
}
