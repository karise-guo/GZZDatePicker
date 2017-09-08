//
//  UIButton+Closure.swift
//  client_swift_fm_a
//
//  Created by 林江锋 on 2017/7/19.
//  Copyright © 2017年 FacilityONE. All rights reserved.
//

import UIKit

extension UIButton{
    
    struct AssociatedClosureClass {
        var eventClosure: (UIButton)->()
    }
    
    private struct AssociatedKeys {
        static var eventClosureObj:AssociatedClosureClass?
    }
    
    private var eventClosureObj: AssociatedClosureClass{
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.eventClosureObj, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        } get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.eventClosureObj) as? AssociatedClosureClass)!
        }
    }
    
    @objc private func eventExcuate(_ sender: UIButton) {
        eventClosureObj.eventClosure(sender)
    }
    
    /// 使用闭包实现 UIButton 点击事件
    ///
    /// - Parameters:
    ///   - controlEvents: 控制事件
    ///   - action: 执行闭包
    func addTarget(for controlEvents: UIControlEvents, action:@escaping (UIButton)->()) {
        
        let eventObj = AssociatedClosureClass(eventClosure: action)
        eventClosureObj = eventObj
        addTarget(self, action: #selector(eventExcuate(_:)), for: controlEvents)
    }
}
