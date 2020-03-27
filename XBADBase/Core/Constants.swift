//
//  Constants.swift
//  stock
//
//  Created by 叶进兵 on 16/8/13.
//  Copyright © 2016年 ye. All rights reserved.
//

import Foundation

public let DEFAULT_TEXT_FONT = 1
public let DEFAULT_PIC_MODE = 0

func dPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        var idx = items.startIndex
        let endIdx = items.endIndex
        
        repeat {
            Swift.print(items[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
            idx += 1
        } while idx < endIdx
    #endif
}
