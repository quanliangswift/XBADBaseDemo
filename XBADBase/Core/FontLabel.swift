//
//  FontLabel.swift
//  TopNews
//
//  Created by 叶进兵 on 2017/2/14.
//  Copyright © 2017年 xb. All rights reserved.
//

import UIKit
class EdgeInsetsLabel : UILabel {
    fileprivate var contentInset : UIEdgeInsets = UIEdgeInsets.zero
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInset))        
    }
    func setContentInset(contentInset : UIEdgeInsets) {
        self.contentInset = contentInset
        self.setNeedsDisplay()
    }
}
class FontLabel: EdgeInsetsLabel {
    
    var fontSize: CGFloat?
    var fontScale: Float = 1.0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fontSize = font.pointSize
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fontSize = font.pointSize
    }
    
    override func awakeFromNib() {
        fontSize = font.pointSize
    }
    
    //设置attributedText之后不会显示省略，这时候手动设置一下
    override var attributedText: NSAttributedString? {
        didSet {
            self.lineBreakMode = .byTruncatingTail
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func setFontScale(scale: Float, weight : UIFont.Weight? = nil) {
        if scale != self.fontScale {
            if UIScreen.main.bounds.width >= 414 {
                self.fontScale = scale * 1.1
            } else {
                self.fontScale = scale
            }
            if weight != nil {
                if #available(iOS 8.2, *) {
                    self.font = UIFont.systemFont(ofSize: self.fontSize! * CGFloat(fontScale), weight: weight!)
                } else {
                    // Fallback on earlier versions
                    self.font = self.font.withSize(self.fontSize! * CGFloat(fontScale))
                }
            } else {
                self.font = self.font.withSize(self.fontSize! * CGFloat(fontScale))
            }
        }
    }

}
