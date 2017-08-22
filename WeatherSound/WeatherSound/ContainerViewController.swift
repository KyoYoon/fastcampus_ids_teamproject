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
class ContainerViewController: UIViewController, MiniPlayerViewDelegate {
    
    let miniPlayerView: MiniPlayerView = MiniPlayerView()
    
    
    fileprivate var musicPlayerVC: MusicPlayerViewController!
    private var animator: ARNTransitionAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.setupAnimator()
        configureObservers()
        self.musicPlayerVC.musicPlayer = WSPlayer(delegate: self.musicPlayerVC)
    }

    
    func configureObservers()
    {
//        NotificationCenter.default.addObserver(self.musicPlayerVC, selector: #selector(musicPlayerVC.loadWSPlayerItems), name: Notification.Name("PlayItemsLoaded"), object: nil)

        NotificationCenter.default.addObserver(self.musicPlayerVC, selector: #selector(musicPlayerVC.loadFirstSongOfList), name: Notification.Name("FirstSongOfListLoaded"), object: nil)
        
        NotificationCenter.default.addObserver(self.musicPlayerVC, selector: #selector(musicPlayerVC.playSongSelectedFromMain), name: Notification.Name("SongSelectedFromMain"), object: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpUI()
    {
        let storyboard = UIStoryboard(name: "DY", bundle: nil)
        self.musicPlayerVC = storyboard.instantiateViewController(withIdentifier: "MusicPlayerViewController") as? MusicPlayerViewController
        self.musicPlayerVC?.modalPresentationStyle = .overFullScreen
        
        
        DataCenter.shared.delegate = self.musicPlayerVC
        
        self.miniPlayerView.delegate = self
        self.musicPlayerVC.delegate = self.miniPlayerView
        self.miniPlayerView.backgroundColor = .clear
        self.view.addSubview(miniPlayerView)
        self.miniPlayerView.anchor(top: nil, left: self.view.leftAnchor, right: self.view.rightAnchor, bottom: self.view.bottomAnchor, topConstant: 0, leftConstant: 0, rightConstant: 0, bottomConstant: 0, width: self.view.frame.width, height: 55, centerX: self.view.centerXAnchor, centerY: nil)
        
        let color = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.3)
        self.miniPlayerView.miniPlayerButton.setBackgroundImage(self.generateImageWithColor(color), for: .highlighted)
    }
    
    func setupAnimator() {
        guard let musicPlayerVC = self.musicPlayerVC else { return }
        let animation = MusicPlayerTransitionAnimation(rootVC: self, modalVC: self.musicPlayerVC)
        animation.completion = { [weak self] isPresenting in
            if isPresenting {
                guard let _self = self else { return }
                
                let modalGestureHandler = TransitionGestureHandler(targetVC: _self, direction: .bottom)
                modalGestureHandler.registerGesture((self?.musicPlayerVC?.view)!)
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
    
    func presentMusicPlayerController()
    {
        self.present(musicPlayerVC!, animated: true, completion: nil)
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
    
//    override func remoteControlReceived(with event: UIEvent?)
//    {
//        guard let musicPlayer = self.musicPlayerVC.musicPlayer else { return }
//        if event?.type == .remoteControl
//        {
//            switch event!.subtype
//            {
//            case .remoteControlPlay :
//                musicPlayer.play()
//            case .remoteControlPause :
//                musicPlayer.pause()
//            case .remoteControlNextTrack :
//                musicPlayer.playNext()
//            case .remoteControlPreviousTrack:
//                musicPlayer.playPrevious()
//            case .remoteControlTogglePlayPause:
//                if musicPlayer.state == .playing
//                {
//                    musicPlayer.pause()
//                } else
//                {
//                    musicPlayer.play()
//                }
//            default:
//                break
//            }
//        }
//    }

    
}
