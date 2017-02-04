//
//  FWPresentationController.swift
//  flutterwave
//
//  Created by Johnson Ejezie on 10/12/2016.
//  Copyright © 2016 johnsonejezie. All rights reserved.
//

import UIKit

class FWPresentationController: UIPresentationController {
    
    // MARK: - Properties
    fileprivate var dimmingView: UIView!
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)
            frame.origin.y = (containerView!.frame.height - frame.size.height)/2.0
            frame.origin.x = (containerView!.frame.width - frame.size.width)/2.0
 
        return frame
    }
    
    // MARK: - Initializers
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        setupDimmingView()
    }
    
    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(dimmingView, at: 0)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|", options: [], metrics: nil, views: ["dimmingView": dimmingView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|", options: [], metrics: nil, views: ["dimmingView": dimmingView]))
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        var width = parentSize.width*0.9
        
        let height = parentSize.height*0.8
        if UIDevice.current.userInterfaceIdiom == .pad {
            width = 380
            
        }
        
        if UIDevice.current.orientation.isLandscape {
            
            return CGSize(width:width, height: height)
        }
        
        if width > 414 {
            width = 380
        }
        
        
        
        
        return CGSize(width: width, height: height)
    }
}

// MARK: - Private
private extension FWPresentationController {
    
    func setupDimmingView() {
        dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        dimmingView.alpha = 0.0
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        dimmingView.addGestureRecognizer(recognizer)
    }
    
    dynamic func handleTap(recognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }
}
