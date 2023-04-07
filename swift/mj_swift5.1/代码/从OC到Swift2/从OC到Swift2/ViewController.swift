//
//  ViewController.swift
//  从OC到Swift2
//
//  Created by 沈春兴 on 2022/7/13.
//

import UIKit

//dispatch_once在swift被废弃了，可以用类型属性或者全局变量来实现只执行一次的代码
//全局变量
fileprivate let initTask2: Void = {
    print("initTask2---")
}()

class ViewController: UIViewController {
    //类型属性
    static let initTask1:Void = {
       print("initTask1---")
    }()
    
    
    //多线程加锁：DispatchSemaphore信号量
    class Cache {
        private static var data = [String: Any]()
        private static var lock = DispatchSemaphore(value: 1)
            static func set(_ key: String, _ value: Any) {
               lock.wait()
               defer { lock.signal() }
               data[key] = value
           }
    }
    
    //使用普通锁
    class CustomClass {
        private static var lock = NSLock()
        static func set(_ key: String, _ value: Any) {
           lock.lock()
           defer { lock.unlock() }
        }
    }
    
    //使用递归锁
    class CustomClass2 {
        private static var lock = NSRecursiveLock()
        static func set(_ key: String, _ value: Any) {
           lock.lock()
           defer { lock.unlock() }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let img = R.image.logo
        let font = R.font.arial(12)
        
        
        let _ = Self.initTask1
        let _ = initTask2
    }

}


//资源名管理
enum R {
    enum image {
        static var logo = UIImage(named:"logo")
    }
    enum font {
        static func arial(_ size : CGFloat) -> UIFont? {
            UIFont(name: "Arial", size: size)
        }
    }
}



