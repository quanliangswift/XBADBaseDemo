//
//  UIColorExtension.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/4/3.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import Foundation
extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat((hex & 0xff0000) >> 16) / 255.0,
                            green: CGFloat((hex & 0xff00) >> 8) / 255.0,
                            blue: CGFloat((hex & 0xff)) / 255.0,
                            alpha: alpha)
    }
}
