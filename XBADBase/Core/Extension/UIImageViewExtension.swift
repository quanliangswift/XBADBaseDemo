//
//  UIImageViewExtension.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/4/2.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import UIKit
import SDWebImage
extension UIImageView :CAAnimationDelegate{
    
   
    
    //网络加载图片，带有圆角
    func sd_xb_loadImage(with url:URL?, placeholderImage : UIImage? = nil, options: SDWebImageOptions = [], completed: SDExternalCompletionBlock? = nil) {
        if url == nil {
            self.image = placeholderImage
            return
        }
        self.sd_setImage(with: url, placeholderImage: placeholderImage, options: (options.isEmpty ? .lowPriority : options), completed: { (image, error, cacheType, url) in
            completed?(image, error, cacheType, url)
            if cacheType == .none { // 只有当缓存中没有图片，也就是首次加载时才实现CATransition动画
                let transition:CATransition = CATransition()
                transition.type = CATransitionType.fade // 褪色效果，渐进效果的基础
                transition.duration = 0.2
                transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut) // 先慢后快再慢
                transition.delegate = self
                self.layer.add(transition, forKey: "newVoteTimeline") // 在layer中加入动画，并约定好该动画的key
            }
        })
    }
}
