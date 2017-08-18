//
//  SideMenuTransition.swift
//  WeatherSound
//
//  Created by HyunJomi on 2017. 8. 13..
//  Copyright © 2017년 정교윤. All rights reserved.
//

import UIKit

class SideMenuTransition: NSObject, UIViewControllerAnimatedTransitioning {

    var isPresent: Bool = false
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if self.isPresent {
            self.presentWithTransition(transitionContext)
        }
        else {
            self.dismissWithTransition(transitionContext)
        }
    }
    
    func presentWithTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
        let toVC: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let fromVC: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let containerView: UIView = transitionContext.containerView
       
        let dimView: UIView = UIView(frame: containerView.bounds)
        dimView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        containerView.addSubview(dimView)
        containerView.addSubview(toVC.view)
        
//        let rect = toVC.view.frame
        let rect = UIScreen.main.bounds
        toVC.view.frame = CGRect(x: rect.width*0.6, y: rect.minY, width: rect.width, height: rect.height)

        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            toVC.view.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
            fromVC.view.frame = CGRect(x: -rect.width*0.6, y: 0, width: rect.width, height: rect.height)
            
        }) { (finished: Bool) in
             transitionContext.completeTransition(true)
        }
    
    }
    
    func dismissWithTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
        let toVC: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        let fromVC: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        
        let rect = toVC.view.bounds
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            toVC.view.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
            fromVC.view.frame = CGRect(x: rect.width*0.6, y: 0, width: rect.width, height: rect.height)
        }) { (finished: Bool) in
            transitionContext.completeTransition(true)
        }
    }
}
