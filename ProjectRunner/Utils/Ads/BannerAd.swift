//
//  BannerAd.swift
//  PhotoRoad
//
//  Created by 워뇨옹 on 6/17/24.
//


import Foundation
import GoogleMobileAds
import SwiftUI

struct GADBanner: UIViewControllerRepresentable {
#if DEBUG
    private let adID = "ca-app-pub-6235545617614297/1325117271"
#else
    private let adID = "ca-app-pub-3940256099942544/6300978111"
#endif
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let view = GADBannerView(adSize: GADAdSizeBanner)
        let viewController = UIViewController()
        
        view.adUnitID = adID
        view.rootViewController = viewController
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: GADAdSizeBanner.size)
        view.load(GADRequest())
        return viewController
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
