//
//  RewardAd.swift
//  PhotoRoad
//
//  Created by 워뇨옹 on 6/17/24.
//

import GoogleMobileAds
import Foundation

final class RewardedAd {
#if DEBUG
    private let adID = "ca-app-pub-3940256099942544/1712485313"
#else
    private let adID = "ca-app-pub-6235545617614297/4399238682"
#endif
    var rewardedAd: GADRewardedAd?
    
    init() {
        load()
    }
    
    func load(){
        let request = GADRequest()
        // add extras here to the request, for example, for not presonalized Ads
        GADRewardedAd.load(withAdUnitID: adID, request: request, completionHandler: {rewardedAd, error in
            if error != nil {
                // loading the rewarded Ad failed :(
                return
            }
            self.rewardedAd = rewardedAd
        })
    }
    
    func showAd(rewardFunction: @escaping () -> Void) -> Bool {
        guard let rewardedAd = rewardedAd else {
            return false
        }
        
        guard let root = UIApplication.shared.keyWindowPresentedController else {
            return false
        }
        rewardedAd.present(fromRootViewController: root, userDidEarnRewardHandler: rewardFunction)
        return true
    }
}
