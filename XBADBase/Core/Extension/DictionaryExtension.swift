//
//  DictionaryExtension.swift
//  TopNews
//
//  Created by leiyuncun on 2018/12/12.
//  Copyright © 2018 xb. All rights reserved.
//

import Foundation

extension Dictionary {
    func toJSONString() -> String? {

        if (JSONSerialization.isValidJSONObject(self)) {
            let data = try? JSONSerialization.data(withJSONObject: self, options: [])
            let jsonString = String(data: data ?? Data(), encoding: .utf8)
            return jsonString
        } else {
            print("JSONSerialization error")
            return nil
        }
        
    }
}



