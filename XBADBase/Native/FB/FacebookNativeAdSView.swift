//
//  FacebookNativeAdSView.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/4/2.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import UIKit
import FBAudienceNetwork
import SnapKit
class FacebookNativeAdSView: XBNativeAdBaseView {
    @IBOutlet weak var adCoverMediaView: FBMediaView!
    @IBOutlet weak var adCallToActionButton: UIButton!
    @IBOutlet weak var adSocialContextLabel: UILabel!
    @IBOutlet weak var adBodyLabel: FontLabel!
    @IBOutlet weak var tagsLabel: UILabel!
  
    @IBOutlet weak var adCoverBgView: UIImageView!
    
    @IBOutlet weak var picWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var picHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var  separationView: UIView!
    
    var adChoicesView: FBAdChoicesView!
    
    var imageWidth: CGFloat = 0
    var imageHeight: CGFloat = 0
   
    var fontScale : Float = 1.0
    
    var nativeAd : FBNativeAd?{
        didSet {
            self.adCallToActionButton.isHidden = true
        
            var tempNativeAd = nativeAd
            tempNativeAd?.delegate = self
           
            if (tempNativeAd != nil) {
                tempNativeAd?.unregisterView()
            }

            self.adBodyLabel.setFontScale(scale: fontScale)
            self.adBodyLabel.text = tempNativeAd?.bodyText
            self.adSocialContextLabel.text = tempNativeAd?.socialContext
            
            self.adCallToActionButton.setTitle(tempNativeAd?.callToAction, for: .normal)
            self.adCallToActionButton.isHidden = false
            
            tempNativeAd?.registerView(forInteraction: self, mediaView: self.adCoverMediaView, iconImageView: nil, viewController: Utils.AppTopViewController(), clickableViews: [self.adCallToActionButton])
            
            self.adChoicesView.nativeAd = tempNativeAd
            adChoicesView.isBackgroundShown = false
            adChoicesView.corner = .bottomLeft
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        haveCallbackImp = true
        setupUI()
    }
    
    func setupUI() {
        imageWidth = CGFloat(kSmallImageWidth)
        imageHeight = imageWidth / 1.43
        
        picWidthConstraint.constant = imageWidth
        picHeightConstraint.constant = imageHeight
        
       adCoverMediaView.snp.makeConstraints { (make) in
            make.edges.equalTo(adCoverBgView)
        }
        adCoverMediaView.delegate = self
        self.adCallToActionButton.isHidden = true
        adCallToActionButton.layer.cornerRadius = 3
        adCallToActionButton.layer.borderColor = UIColor(hex: 0x2691e1).cgColor
        adCallToActionButton.layer.borderWidth = 0.5
        adCallToActionButton.layer.masksToBounds = true
        
        let bgView = UIView()
        self.addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.bottom.equalTo(adCoverMediaView)
            make.width.height.equalTo(20)
        }
        adChoicesView = FBAdChoicesView()
        bgView.addSubview(adChoicesView)
    }
}

extension FacebookNativeAdSView: FBMediaViewDelegate {
    func mediaViewDidLoad(_ mediaView: FBMediaView) {
    }
}
extension FacebookNativeAdSView: FBNativeAdDelegate {
    func nativeAdDidClick(_ nativeAd: FBNativeAd) {
        logDelegate?.onNativeAdClick(title: nativeAd.headline, desc: nativeAd.bodyText)
    }
    func nativeAdWillLogImpression(_ nativeAd: FBNativeAd) {
        logDelegate?.onNativeAdImp()
    }

}
