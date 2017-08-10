//
//  ContainerViewController.swift
//  DYMusicPlayer
//
//  Created by Dong Yoon Han on 8/7/17.
//  Copyright © 2017 DY. All rights reserved.
//

import UIKit
import ARNTransitionAnimator

//미니 플레이어와 음악 플레이어를 가지고 있는 뷰 컨트롤러
//음악을 재생 시킬 곳.
class ContainerViewController: UIViewController {
    
    let miniPlayerView:MiniPlayerView = MiniPlayerView()
    
    fileprivate var musicPlayerVC:MusicPlayerViewController!// = MusicPlayerViewController()

    private var animator : ARNTransitionAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "DY", bundle: nil)
        self.musicPlayerVC = storyboard.instantiateViewController(withIdentifier: "MusicPlayerViewController") as? MusicPlayerViewController
        self.musicPlayerVC?.modalPresentationStyle = .overFullScreen
        
        
        
        
        //        self.miniPlayerView.delegate = self
        self.miniPlayerView.musicPlayerVC = self.musicPlayerVC
        self.view.addSubview(miniPlayerView)
        self.miniPlayerView.anchor(top: nil, left: self.view.leftAnchor, right: self.view.rightAnchor, bottom: self.view.bottomAnchor, topConstant: 0, leftConstant: 0, rightConstant: 0, bottomConstant: 0, width: self.view.frame.width, height: 45, centerX: self.view.centerXAnchor, centerY: nil)
        
        //        self.musicPlayerVC.modalPresentationStyle = .overFullScreen
        
        let color = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.3)
        self.miniPlayerView.miniPlayerButton.setBackgroundImage(self.generateImageWithColor(color), for: .highlighted)
        self.setupAnimator()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupAnimator() {
        guard let musicPlayerVC = self.musicPlayerVC else { return }
        let animation = MusicPlayerTransitionAnimation(rootVC: self, modalVC: musicPlayerVC)
        animation.completion = { [weak self] isPresenting in
            if isPresenting {
                guard let _self = self else { return }
                let modalGestureHandler = TransitionGestureHandler(targetVC: _self, direction: .bottom)
                modalGestureHandler.registerGesture(musicPlayerVC.view)
                modalGestureHandler.panCompletionThreshold = 15.0
                _self.animator?.registerInteractiveTransitioning(.dismiss, gestureHandler: modalGestureHandler)
            } else {
                self?.setupAnimator()
            }
        }
        
        let gestureHandler = TransitionGestureHandler(targetVC: self, direction: .top)
        gestureHandler.registerGesture(self.miniPlayerView)
        gestureHandler.panCompletionThreshold = 15.0
        
        self.animator = ARNTransitionAnimator(duration: 0.5, animation: animation)
        self.animator?.registerInteractiveTransitioning(.present, gestureHandler: gestureHandler)
        
        musicPlayerVC.transitioningDelegate = self.animator
    }
    
    
    fileprivate func generateImageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
}
