//
//  MTGNativeAdSView.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/4/2.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import UIKit

class MTGNativeAdSView: XBNativeAdBaseView {

    @IBOutlet weak var adIconImageView: UIImageView!
    @IBOutlet weak var adCoverMediaView: MTGMediaView!
    @IBOutlet weak var adTitleLabel: UILabel!
    @IBOutlet weak var adCallToActionButton: UIButton!
    @IBOutlet weak var adBodyLabel: FontLabel!
    @IBOutlet weak var adChoicesView: MTGAdChoicesView!
    
    @IBOutlet weak var adChoicesViewWidthCons: NSLayoutConstraint!
    @IBOutlet weak var adChoicesViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var  separationView: UIView!
    @IBOutlet weak var picWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var picHeightConstraint: NSLayoutConstraint!
    var mtgAdModel : MTGAdModel? {
        didSet {
            if mtgAdModel == nil || mtgAdModel?.nativeAd == nil || mtgAdModel?.manager == nil {return}
            self.adCoverMediaView.setMediaSourceWith(mtgAdModel!.nativeAd!, unitId: mtgAdModel!.manager!.currentUnitId)
            self.adTitleLabel.text = mtgAdModel!.nativeAd!.appName
            self.adBodyLabel.text = mtgAdModel!.nativeAd!.appDesc
            self.adCallToActionButton.setTitle(mtgAdModel!.nativeAd!.adCall, for: .normal)
            mtgAdModel!.nativeAd!.loadIconUrlAsync { (image) in
                self.adIconImageView.image = image
            }
            if mtgAdModel!.nativeAd!.adChoiceIconSize == CGSize.zero {
                self.adChoicesView.isHidden = true
            } else {
                self.adChoicesView.isHidden = false
                adChoicesViewWidthCons.constant = mtgAdModel!.nativeAd!.adChoiceIconSize.width
                adChoicesViewHeightCons.constant = mtgAdModel!.nativeAd!.adChoiceIconSize.height
            }
            self.adChoicesView.campaign = mtgAdModel!.nativeAd!
            mtgAdModel!.manager?.delegate = self
            mtgAdModel!.manager?.registerView(forInteraction: self, withClickableViews: [self.adCallToActionButton,self.adCoverMediaView,self], with: mtgAdModel!.nativeAd!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func setupUI() {
       
        let imageWidth = CGFloat(kSmallImageWidth)
        let imageHeight = imageWidth / 1.43
        
        picWidthConstraint.constant = imageWidth
        picHeightConstraint.constant = imageHeight
    }
}
extension MTGNativeAdSView: MTGNativeAdManagerDelegate {
    func nativeAdDidClick(_ nativeAd: MTGCampaign, nativeManager: MTGNativeAdManager) {
        logDelegate?.onNativeAdClick(title: nativeAd.appName, desc: nativeAd.appDesc)
    }
    func nativeAdImpression(with type: MTGAdSourceType, nativeManager: MTGNativeAdManager) {
        print("曝光了")
        logDelegate?.onNativeAdImp()
    }

}
