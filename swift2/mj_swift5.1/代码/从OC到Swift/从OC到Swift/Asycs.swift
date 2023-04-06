//
//  Asycs.swift
//  从OC到Swift
//
//  Created by 沈春兴 on 2022/7/8.
//

import Foundation


public struct Asycs {
    //多线程开发
    public typealias Task = () -> Void
    public static func async(_ task: @escaping Task) {
       _async(task)
    }
    public static func async(_ task: @escaping Task, _ mainTask: @escaping Task) {
       _async(task, mainTask)
    }

    private static func _async(_ task: @escaping Task, _ mainTask: Task? = nil) {
        let item = DispatchWorkItem(block: task)
        DispatchQueue.global().async(execute: item)
        if let main = mainTask {
           item.notify(queue: DispatchQueue.main, execute: main)
        }
    }
    
    
   @discardableResult
   public static func asyncDelay(_ seconds: Double,
                                 _ task: @escaping Task) -> DispatchWorkItem {
       return _asyncDelay(seconds, task)
   }
    
   @discardableResult
   public static func asyncDelay(_ seconds: Double,
                                 _ task: @escaping Task,_ mainTask: @escaping Task) -> DispatchWorkItem {
        return _asyncDelay(seconds, task, mainTask)
   }
    
   private static func _asyncDelay(_ seconds: Double,_ task: @escaping Task,
                                   _ mainTask: Task? = nil) -> DispatchWorkItem {
       let item = DispatchWorkItem(block: task)
       DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + seconds, execute: item)
       if let main = mainTask {
       item.notify(queue: DispatchQueue.main, execute: main)
       }
       return item
       
   }
    
}
