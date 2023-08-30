//
//  AppDelegate.swift
//  自己实现简单App日志系统
//
//  Created by 沈春兴 on 2023/8/14.
//

import UIKit

/**
 第三方框架，比如Firebase Crashlytics，它内部是如何捕获OC和Swift异常的？
 
 第三方框架如 Firebase Crashlytics 是使用自己的机制来捕获和处理应用内的异常和错误。虽然具体实现可能因框架而异，但一般来说，它们会通过以下方式来捕获 OC 和 Swift 异常：

 Signal 机制： 框架可能会使用底层的信号机制来捕获崩溃。在应用崩溃时，操作系统会发送信号，例如 SIGABRT、SIGSEGV 等，作为崩溃的标识。框架可以设置一个信号处理器来捕获这些信号，然后在处理器中记录相关信息并上传到服务器。

 Exception 捕获： 在 Objective-C 中，异常处理机制通过 @try、@catch 和 @throw 关键字实现。框架可能会使用这些关键字来捕获 Objective-C 异常。对于 Swift，框架可能会使用 Swift 的错误处理机制来捕获错误。

 Uncaught Exception Handler： 类似于你之前`，框架可能会设置一个全局的未捕获异常处理器，以捕获应用中未处理的异常和错误。这个处理器可以在应用崩溃之前记录错误信息、上传数据等。

 Swizzling： 框架可能会使用方法交换（Method Swizzling）来重写或增加某些方法的实现，以便在方法被调用时记录信息。这样可以捕获到异常发生的上下文和信息。

 符号化（Symbolication）： 框架可能会使用符号化技术来解析堆栈跟踪信息，将地址转换为具体的方法名和行号，从而更准确地确定异常的位置
 */

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var logFilePath: URL?

        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            // 设置全局异常处理
            setupGlobalExceptionHandler()
            
            return true
        }

        func setupGlobalExceptionHandler() {
            // 设置未捕获异常处理器（只能捕获OC）
            NSSetUncaughtExceptionHandler { exception in
                self.handleUncaughtException(exception)
            }
            
            // 设置Swift错误处理器，该方案已经弃用，swift有自己的异常捕获机制do-catch。应该在需要捕获异常的地方添加do-catch代码去捕获。swift没有全局捕获异常的方法。
//            Thread.setDefaultUncaughtExceptionHandler { exception in
//                self.handleSwiftError(exception)
//            }
        }
        
        func handleUncaughtException(_ exception: NSException) {
            // 在这里你可以记录异常信息到日志文件
            logExceptionToFile(exception)
            
            // 在这里你可以将异常信息发送到服务器
            sendExceptionToServer(exception)
            
            // 在这里你可以向用户显示提示信息
            showAlertToUser(message: "应用发生异常，我们已经收到您的反馈。")
            
            // 最后，让应用崩溃
            exception.raise()
        }
        
        func handleSwiftError(_ exception: NSException) {
            // 在这里你可以记录异常信息到日志文件
            logExceptionToFile(exception)
            
            // 在这里你可以将异常信息发送到服务器
            sendExceptionToServer(exception)
            
            // 在这里你可以向用户显示提示信息
            showAlertToUser(message: "应用发生错误，我们已经收到您的反馈。")
            
            // 最后，让应用崩溃
            exception.raise()
        }
        
    //异常日志记录到文件
    func logExceptionToFile(_ exception: NSException) {
        guard let logFilePath = logFilePath else {
            return
        }
        
        let logMessage = "Exception: \(exception)\n"
        do {
            if let data = logMessage.data(using: .utf8) {
                if !FileManager.default.fileExists(atPath: logFilePath.path) {
                    FileManager.default.createFile(atPath: logFilePath.path, contents: nil, attributes: nil)
                }
                let fileHandle = try FileHandle(forWritingTo: logFilePath)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } catch {
            print("Error writing to log file: \(error)")
        }
    }
        
    // 将异常信息发送到服务器
    // 通过网络请求将异常信息发送到服务器
    func sendExceptionToServer(_ exception: NSException) {
            guard let url = URL(string: "https://yourserver.com/upload_exception") else {
                return
            }
            
            let logMessage = "Exception: \(exception)"
            
            let parameters: [String: Any] = [
                "logMessage": logMessage
            ]
            
            Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        print("Exception sent successfully: \(value)")
                    case .failure(let error):
                        print("Error sending exception: \(error)")
                    }
                }
        }
        
        func showAlertToUser(message: String) {
            // 在UI上显示一个提示框，通知用户发生了异常
            let alert = UIAlertController(title: "应用发生问题", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
            window?.rootViewController?.present(alert, animated: true, completion: nil)
        }

    
    //日志写入本地文件
    func setupLogFilePath() {
           if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
               let logFileName = "app_log.txt"
               logFilePath = documentsDirectory.appendingPathComponent(logFileName)
           }
       }

       
}

