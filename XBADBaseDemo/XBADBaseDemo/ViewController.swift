//
//  ViewController.swift
//  XBADBaseDemo
//
//  Created by 全尼古拉斯 on 2020/3/25.
//  Copyright © 2020 全尼古拉斯. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    // 开始广告
    func fetchAdConfig() {
        XbSDKIntegrationManager.shared.registerConfig(xbAdIntegration: XbAdIntegration.init())
    }
    func registerAd() {
        XbAdManager.shared.registerAd(by: ["facebook", "admob", "appnext", "baidu", "mintegral"])
        XBRewardVideoManager.shared.registerAd(by: ["facebook", "admob", "mintegral"])
    }
    
    func getCell() {
        let cell = UITableView().dequeueReusableCell(withIdentifier: "nativeAdcell", for: IndexPath.init(row: 0, section: 0))
    }
}

class BaseAdvertCell: UITableViewCell {
//    var news: News!{
//        didSet {
//            adUIView = XbAdAdapter.shared.getNativeAdView(source: source, type: type, ad: ad)
//            adUIView.logDelegate = self
//            self.addSubview(adUIView)
//            adUIView.snp.makeConstraints { (make) in
//                make.top.bottom.equalToSuperview()
//                make.centerX.centerY.equalToSuperview()
//                make.leading.equalToSuperview().offset(13)
//                make.trailing.equalToSuperview().offset(13)
//            }
//        }
//    }
//    var trackerCallBack: ((News)->())?
//    var haveCallbackImp: Bool = false

    var source: String!
    var type: XbAdAdapter.NativeAdViewType!
    var ad: Any!
    var adUIView: XBNativeAdBaseView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onClickAdvertContent)))
        
    }
    deinit {
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    

    @objc func onClickAdvertContent() {
    }
//
//    @objc func willDisplay() {
//        news.startImp()
//    }
//
//    @objc func endDisplay() {
//        if news.advert?.type == "sdk" && (self.isKind(of: FacebookNativeAdCell.self) || self.isKind(of: GoogleNativeAdCell.self)) {
//            var title: String?
//            var desc: String?
//            if self.isKind(of: FacebookNativeAdCell.self) {
//                title = (self as? FacebookNativeAdCell)?.nativeAd?.headline
//                desc = (self as? FacebookNativeAdCell)?.nativeAd?.bodyText
//            } else if self.isKind(of: GoogleNativeAdCell.self) {
//                title = (self as? GoogleNativeAdCell)?.nativeAd?.headline
//                desc = (self as? GoogleNativeAdCell)?.nativeAd?.body
//            }
//           logSSPAdvertImp(news: news, title: title, desc: desc)
//        } else {
//            logSSPAdvertImp(news: news, title: nil, desc: nil)
//        }
//        didScroll()
//    }
//
//    func didScroll() {
//        if self.superview == nil { return }
//        if (news.advert?.imptrackers?.count ?? 0) == 0 { return }
//        if haveCallbackImp {return}
//
//        let window = UIApplication.shared.keyWindow
//        let cellRect = self.convert(self.bounds, to: window)
//        var cellSuperView = self.superview
//        //  查找到cell所在的tableview
//        while cellSuperView != nil && !cellSuperView!.isKind(of: UITableView.self) {
//            cellSuperView = cellSuperView?.superview
//        }
//        if cellSuperView == nil || !cellSuperView!.isKind(of: UITableView.self) {
//            return
//        }
//
//        let superViewRect = cellSuperView!.convert(cellSuperView!.bounds, to: window)
//        var impRate: CGFloat = 0
//        impRate = Utils.getImpRate(impRect: cellRect, targetRect: superViewRect)
//
//        let impTime = news.getCurrentImp()
//        if impRate < 0 || impRate > 1 {
//            return
//        }
//        normalImpTracker(impRate: impRate, impTime: impTime)
//    }

}

extension BaseAdvertCell: XbNativeAdlogDelegate {
    func onNativeAdClick(title: String?, desc: String?) {
        
    }
    
    func onNativeAdImp() {
        
    }
}
