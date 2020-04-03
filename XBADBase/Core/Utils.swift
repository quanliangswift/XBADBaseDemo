//
//  Utils.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/3/30.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import Foundation
let kSmallImageWidth = (kScreenWidth - 30) / 3
let kContentViewWidth = (kScreenWidth - 26)
let kNavBarHeight : CGFloat = 44
let kTabBarHeight : CGFloat = 49
let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height
let kScreenWidthScale = kScreenWidth / 375.0 // 当前屏幕与 375

class Utils : NSObject {
/// 找到顶部VC，用来弹出提示框
       ///
       /// - Returns:顶部VC
   class func AppTopViewController() -> UIViewController? {
       let topVC = UIApplication.shared.keyWindow?.rootViewController
       return Utils.topViewControllerWithRootViewController(viewController: topVC)
   }
   class func topViewControllerWithRootViewController(viewController : UIViewController?) -> UIViewController? {
       if viewController == nil {return nil}
       
       if viewController?.presentedViewController != nil {
           //modal出来的 控制器
           return Utils.topViewControllerWithRootViewController(viewController: viewController?.presentedViewController)
       } else if let tabVC = viewController as? UITabBarController {
           // tabBar 的跟控制器
           if let selectVC = tabVC.selectedViewController {
               return Utils.topViewControllerWithRootViewController(viewController: selectVC)
           }
           return nil
       } else if viewController?.isKind(of: UINavigationController.self) == true {
           // 控制器是 nav
           return Utils.topViewControllerWithRootViewController(viewController: (viewController as! UINavigationController).visibleViewController)
       } else {
           if viewController?.isKind(of: UIAlertController.self) ?? false {
               return viewController?.presentingViewController
           }
           return viewController
       }
   }
   
}
