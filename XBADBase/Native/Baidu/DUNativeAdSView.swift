//
//  DUNativeAdSView.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/4/2.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import UIKit
import DUModuleSDK
import SnapKit


class DUNativeAdSView: XBNativeAdBaseView {
    @IBOutlet weak var adIconImageView: UIImageView!
    @IBOutlet weak var adImageView: UIImageView!
    @IBOutlet weak var adTitleLabel: UILabel!
    @IBOutlet weak var adCallToActionButton: UIButton!
    
    @IBOutlet weak var adBodyLabel: FontLabel!
    @IBOutlet weak var tagsLabel: UILabel!
    
    
    @IBOutlet weak var picWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var picHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var  separationView: UIView!
    var fontScale : Float = 1.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let imageWidth = CGFloat(kSmallImageWidth)
        let imageHeight = imageWidth / 1.43
        
        picWidthConstraint.constant = imageWidth
        picHeightConstraint.constant = imageHeight
        
        self.adCallToActionButton.isHidden = true
        adCallToActionButton.layer.cornerRadius = 3
        adCallToActionButton.layer.borderColor = UIColor(hex: 0x2691e1).cgColor
        adCallToActionButton.layer.borderWidth = 0.5
        adCallToActionButton.layer.masksToBounds = true
    }
    var nativeAd : DUNativeAd?{
        didSet {
            self.adCallToActionButton.isHidden = true
            var tempNativeAd = nativeAd
            
            tempNativeAd?.delegate = self
            
            if (tempNativeAd != nil) {
                tempNativeAd?.unregisterView()
            }
            
            self.adTitleLabel.text = tempNativeAd?.title
            
            if #available(iOS 8.2, *) {
                self.adBodyLabel.setFontScale(scale: fontScale, weight: UIFont.Weight.medium)
            } else {
                self.adBodyLabel.setFontScale(scale: fontScale)
            }
            
            self.adBodyLabel.text = tempNativeAd?.shortDesc
            self.adCallToActionButton.setTitle(tempNativeAd?.callToAction, for: .normal)
            self.adCallToActionButton.isHidden = false
            if let urlString = tempNativeAd?.iconUrl, let url = URL.init(string: urlString) {
                adIconImageView.sd_xb_loadImage(with: url)
                adIconImageView.isHidden = false
                tagsLabel.snp.updateConstraints({ (make) in
                    make.left.equalTo((adIconImageView?.snp.left)!).offset(37)
                })
            } else {
                adIconImageView.isHidden = true
                tagsLabel.snp.updateConstraints({ (make) in
                    make.left.equalTo(adIconImageView.snp.left).offset(0)
                })
            }
            adImageView.sd_xb_loadImage(with: URL.init(string: tempNativeAd?.imgeUrl ?? ""))
            tempNativeAd?.registerView(forInteraction: self, with: Utils.AppTopViewController(), withClickableViews: [self.adCallToActionButton,self.adImageView,self])
        }
    }
}
extension DUNativeAdSView : DUNativeAdDelegate {
    func nativeAdDidClick(_ nativeAd: DUNativeAd) {
        logDelegate?.onNativeAdClick(title: nativeAd.title, desc: nativeAd.shortDesc)
    }
    func nativeAdWillLogImpression(_ nativeAd: DUNativeAd) {
        logDelegate?.onNativeAdImp()
    }
}
