//
//  FacebookNativeAdView.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/4/2.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import UIKit
import FBAudienceNetwork
import SnapKit
class FacebookNativeAdView: XBNativeAdBaseView {
    @IBOutlet weak var adIconImageView: UIImageView!
    @IBOutlet weak var adCoverMediaView: FBMediaView!
    @IBOutlet weak var adTitleLabel: FontLabel!
    @IBOutlet weak var adCallToActionButton: UIButton!
    @IBOutlet weak var adSocialContextLabel: UILabel!
    @IBOutlet weak var adBodyLabel: FontLabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var sponsoredLabel: UILabel!

    @IBOutlet weak var  separationView: UIView!
    @IBOutlet weak var adChoicesView: FBAdChoicesView!
    var fontScale : Float = 1.0
    
    var nativeAd : FBNativeAd? {
        didSet {
            
            self.adCallToActionButton.isHidden = true
            var tempNativeAd = nativeAd
            tempNativeAd?.delegate = self
            
            if (tempNativeAd != nil && tempNativeAd!.isAdValid) {
                tempNativeAd?.unregisterView()
            }
            
            self.adTitleLabel.text = tempNativeAd?.headline
            
            if #available(iOS 8.2, *) {
                self.adBodyLabel.setFontScale(scale: fontScale, weight: UIFont.Weight.medium)
            } else {
                self.adBodyLabel.setFontScale(scale: fontScale)
            }
            
            sponsoredLabel.text = tempNativeAd?.sponsoredTranslation
            self.adBodyLabel.text = tempNativeAd?.bodyText
            self.adSocialContextLabel.text = tempNativeAd?.socialContext
            self.adCallToActionButton.setTitle(tempNativeAd?.callToAction, for: .normal)
            self.adCallToActionButton.isHidden = false
            
            tempNativeAd?.registerView(forInteraction: self, mediaView: self.adCoverMediaView, iconImageView: adIconImageView, viewController: Utils.AppTopViewController(), clickableViews: [self.adCallToActionButton])
            self.adChoicesView.nativeAd = tempNativeAd
            adChoicesView.isBackgroundShown = false
            adChoicesView.corner = .topRight
            
            print("fb tempNativeAd?.aspectRatio--- ",tempNativeAd?.aspectRatio)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        haveCallbackImp = true
        setupUI()
    }
    

    func setupUI() {
        adCoverMediaView.snp.updateConstraints { (make) in
            make.height.equalTo(adCoverMediaView.snp.width).multipliedBy(1/1.79)
        }
        adCoverMediaView.delegate = self
        self.adCallToActionButton.isHidden = true
        adCallToActionButton.layer.cornerRadius = 3
        adCallToActionButton.layer.borderColor = UIColor(hex: 0x2691e1).cgColor
        adCallToActionButton.layer.borderWidth = 0.5
        adCallToActionButton.layer.masksToBounds = true
        
    }
    
    static func cellHeight(titleStr: String, advertWidth: CGFloat = kContentViewWidth) -> CGFloat {
        if titleStr == "" {
            let height = advertWidth / 1.79 + 24 + 50
            return height
        }
        let paraph = NSMutableParagraphStyle()
        paraph.lineSpacing = 2
        let titleAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                                                               NSAttributedString.Key.paragraphStyle: paraph]
        
        let size = CGSize(width: advertWidth, height: 1000)
        var titleHeight = (titleStr as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: titleAttributes, context: nil).size.height
        
        let line = ceil(titleHeight / (UIFont.systemFont(ofSize: 16).lineHeight + paraph.lineSpacing/2))
        if line > 2 {
            titleHeight = titleHeight * 2 / line
        }
        
        let height = titleHeight + advertWidth / 1.79 + 24 + 50
        return height
    }
}
extension FacebookNativeAdView : FBMediaViewDelegate {
    func mediaViewDidLoad(_ mediaView: FBMediaView) {
    }
    
}
extension FacebookNativeAdView : FBNativeAdDelegate {
    func nativeAdDidClick(_ nativeAd: FBNativeAd) {
        logDelegate?.onNativeAdClick(title: nativeAd.headline, desc: nativeAd.bodyText)
    }
    func nativeAdWillLogImpression(_ nativeAd: FBNativeAd) {
        logDelegate?.onNativeAdImp()
    }
}
