//
//  ViewController.swift
//  FPS监控
//
//  Created by 沈春兴 on 2023/8/13.
//

import UIKit

/**
 FPS监控。要保持流畅的UI交互，App 刷新率应该当努力保持在 60fps。FPS的监控实现原理
 
 通过`CADisplayLink`的实现方式，并真机测试之后，确实是可以在很大程度上满足了监控`FPS`的业务需求和为提高用户体验提供参考，但是和`Instruments`的值可能会有些出入。下面我们来讨论下使用`CADisplayLink`的方式，可能存在的问题。 (1). 和`Instruments`值对比有出入，原因如下: `CADisplayLink`运行在被添加的那个`RunLoop`之中（一般是在主线程中），因此它只能检测出当前`RunLoop`下的帧率。RunLoop中所管理的任务的调度时机，受任务所处的`RunLoopMode`和CPU的繁忙程度所影响。所以想要真正定位到准确的性能问题所在，最好还是通过`Instrument`来确认。 (2). 使用`CADisplayLink`可能存在的循环引用问题。
 */
class LSLWeakProxy: NSObject {
    weak var target: NSObjectProtocol?

    init(target: NSObjectProtocol) {
        self.target = target
        super.init()
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }

    override func responds(to aSelector: Selector!) -> Bool {
        return target?.responds(to: aSelector) ?? super.responds(to: aSelector)
    }
}

class LSLFPSMonitor: UILabel {

    private var link: CADisplayLink!
    private var count: Int = 0
    private var lastTime: TimeInterval = 0.0
    private var fpsColor: UIColor = UIColor.green
    public var fps: Double = 0.0

    // MARK: - Initialization

    override init(frame: CGRect) {
        var f = frame
        if f.size == CGSize.zero {
            f.size = CGSize(width: 55.0, height: 22.0)
        }
        super.init(frame: f)

        setupUI()

        link = CADisplayLink(target: LSLWeakProxy(target: self), selector: #selector(tick))
        link.add(to: .current, forMode: .common)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        link.invalidate()
    }

    private func setupUI() {
        textColor = UIColor.white
        textAlignment = .center
        font = UIFont(name: "Menlo", size: 12.0)
        backgroundColor = UIColor.black
    }

    // MARK: - Actions

    @objc private func tick(link: CADisplayLink) {
        //模拟卡顿
        if Int.random(in: 0...100) < 5 {
                   Thread.sleep(forTimeInterval: 0.1)
               }
        
        guard lastTime != 0 else {
            lastTime = link.timestamp
            return
        }

        count += 1
        let delta = link.timestamp - lastTime
        guard delta >= 1.0 else {
            return
        }

        lastTime = link.timestamp
        fps = Double(count) / delta
        let fpsText = String(format: "%.2f FPS", fps)
        count = 0

        if fps > 55.0 {
            fpsColor = UIColor.green
        } else if fps >= 50.0 && fps <= 55.0 {
            fpsColor = UIColor.yellow
        } else {
            fpsColor = UIColor.red
        }

        let attrMStr = NSMutableAttributedString(string: fpsText)
        attrMStr.setAttributes([.foregroundColor: fpsColor], range: NSRange(location: 0, length: attrMStr.length - 3))
        attrMStr.setAttributes([.foregroundColor: UIColor.white], range: NSRange(location: attrMStr.length - 3, length: 3))

        DispatchQueue.main.async {
            self.attributedText = attrMStr
        }
    }
}

class ViewController: UIViewController {

    var fpsMonitor: LSLFPSMonitor!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create an instance of LSLFPSMonitor using weak proxy
        fpsMonitor = LSLFPSMonitor()
        fpsMonitor.frame = CGRect(x: 100, y: 100, width: 100, height: 30)
        view.addSubview(fpsMonitor)
    }
}

