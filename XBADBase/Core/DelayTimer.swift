//
//  Utils.swift
//  TopNews
//  自定义工具类 
//  Created by xb on 2017/8/8.
//  Copyright © 2017年 xb. All rights reserved.
//

import Foundation

@objc class DelayTimer : NSObject {
 
    //延时执行
    typealias Task = (_ cancel : Bool) -> Void
    @discardableResult
    class func delay(_ time: TimeInterval, task: @escaping ()->()) ->  Task? {
        
        func dispatch_later(block: @escaping ()->()) {
            let t = DispatchTime.now() + time
            DispatchQueue.main.asyncAfter(deadline: t, execute: block)
        }
        var closure: (()->Void)? = task
        var result: Task?
        
        let delayedClosure: Task = {
            cancel in
            if let internalClosure = closure {
                if (cancel == false) {
                    DispatchQueue.main.async(execute: internalClosure)
                }
            }
            closure = nil
            result = nil
        }
        
        result = delayedClosure
        
        dispatch_later {
            if let delayedClosure = result {
                delayedClosure(false)
            }
        }
        return result
    }
    
    class func cancel(_ task: Task?) {
        task?(true)
    }
}
