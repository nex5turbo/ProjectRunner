//
//  OpenAd.swift
//  PhotoRoad
//
//  Created by 워뇨옹 on 6/17/24.
//

import GoogleMobileAds

final class OpenAd: NSObject, GADFullScreenContentDelegate {
    private let adID = "ca-app-pub-6235545617614297/1617046726"

    var appOpenAd: GADAppOpenAd?
    var loadTime = Date()
    
    func requestAppOpenAd() {
        let request = GADRequest()
        GADAppOpenAd.load(withAdUnitID: adID,
                          request: request,
                          completionHandler: { (appOpenAdIn, _) in
            self.appOpenAd = appOpenAdIn
            self.appOpenAd?.fullScreenContentDelegate = self
            self.loadTime = Date()
            if let gOpenAd = self.appOpenAd {
                gOpenAd.present(fromRootViewController: (UIApplication.shared.windows.first?.rootViewController)!)
            }
        })
    }
//
//    func tryToPresentAd() {
//        if let gOpenAd = self.appOpenAd, wasLoadTimeLessThanNHoursAgo(thresholdN: 4) {
//            gOpenAd.present(fromRootViewController: (UIApplication.shared.windows.first?.rootViewController)!)
//        } else {
//            self.requestAppOpenAd()
//        }
//    }
//

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("[OPEN AD] Failed: \(error)")
//        requestAppOpenAd()
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//        requestAppOpenAd()
        print("[OPEN AD] Ad dismissed")
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("[OPEN AD] Ad will present")
    }
}
