//
//  FWPresentationManager.swift
//  flutterwave
//
//  Created by Johnson Ejezie on 10/12/2016.
//  Copyright © 2016 johnsonejezie. All rights reserved.
//

import UIKit

final class FWPresentationManager: NSObject {
    var disableCompactHeight = false
}

// MARK: - UIViewControllerTransitioningDelegate
extension FWPresentationManager: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = FWPresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.delegate = self
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FWPresentationAnimator(isPresentation: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FWPresentationAnimator(isPresentation: false)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension FWPresentationManager: UIAdaptivePresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if traitCollection.verticalSizeClass == .compact && disableCompactHeight {
            return .overFullScreen
        } else {
            return .none
        }
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        guard case(.overFullScreen) = style else { return nil }
        
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RotateViewController")
    }
}
