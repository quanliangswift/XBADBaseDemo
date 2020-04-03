//
//  MTGNativeAdView.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/4/2.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import UIKit

class MTGNativeAdView: XBNativeAdBaseView {

   @IBOutlet weak var adIconImageView: UIImageView!
    @IBOutlet weak var adCoverMediaView: MTGMediaView!
    @IBOutlet weak var adTitleLabel: UILabel!
    @IBOutlet weak var adCallToActionButton: UIButton!
    @IBOutlet weak var adBodyLabel: FontLabel!
    @IBOutlet weak var adChoicesView: MTGAdChoicesView!
    
    @IBOutlet weak var adChoicesViewWidthCons: NSLayoutConstraint!
    @IBOutlet weak var adChoicesViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var  separationView: UIView!
    
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
        
    }

    
    static func cellHeight(titleStr: String, advertWidth: CGFloat = kContentViewWidth) -> CGFloat {
        let height = advertWidth / 1.79 + 30 + 50 + 15 + 10
        return height
        
        //        if titleStr == "" {
        //            let height = advertWidth / 1.79 + 30 + 50 + 15 + 10
        //            return height
        //        }
        //        let paraph = NSMutableParagraphStyle()
        //        paraph.lineSpacing = 2
        //        let titleAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
        //                                                               NSAttributedString.Key.paragraphStyle: paraph]
        //
        //        let size = CGSize(width: advertWidth, height: 1000)
        //        var titleHeight = (titleStr as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: titleAttributes, context: nil).size.height
        //        let line = ceil(titleHeight / (UIFont.systemFont(ofSize: 16).lineHeight + paraph.lineSpacing/2))
        //        if line > 2 {
        //            titleHeight = titleHeight * 2 / line
        //        }
        //        let height = titleHeight + advertWidth / 1.79 + 24 + 50 + 10
        //        return height
    }
}
extension MTGNativeAdView: MTGNativeAdManagerDelegate {
    func nativeAdDidClick(_ nativeAd: MTGCampaign, nativeManager: MTGNativeAdManager) {
//        onClickAdvert(title: nativeAd.appName, desc: nativeAd.appDesc)
        logDelegate?.onNativeAdClick(title: nativeAd.appName, desc: nativeAd.appDesc)
    }
    func nativeAdImpression(with type: MTGAdSourceType, nativeManager: MTGNativeAdManager) {
        print("曝光了")
        logDelegate?.onNativeAdImp()
    }

}
