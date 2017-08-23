//
//  MiniPlayerView.swift
//  DYMusicPlayer
//
//  Created by Dong Yoon Han on 8/7/17.
//  Copyright © 2017 DY. All rights reserved.
//

import UIKit

class MiniPlayerView: UIView, MusicPlayerViewControllerDelegate {

    var delegate:MiniPlayerViewDelegate?

    //임시 이미지 바꾸기 위한 플레이버튼 플래그
//    var isPlayingMusic:Bool = false

    
    let miniPlayerButton:UIButton = {
        
        let button = UIButton()
        button.addTarget(self, action: #selector(miniPlayerButtonHandler), for: .touchUpInside)
        return button
    }()
    
    var miniPlayerImageView:UIImageView = {
        let imageView = UIImageView()
//        imageView.image = #imageLiteral(resourceName: "hotdog")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
//        imageView.backgroundColor = .yellow
        return imageView
    }()
    
    var songTitleLabel:UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textAlignment = .left
        return titleLabel
    }()
    
    
    let playOrstopButton:UIButton = {
        
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "MusicPlayer_play"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(playOrStopButtonHandler), for: .touchUpInside)
        return button
    }()
    
    let nextSongButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "MusicPlayer_next"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(nextSongButtonHandler), for: .touchUpInside)
        return button
    }()
    
    let visualEffectView:UIVisualEffectView = {
        let blurEffect:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        return blurEffectView
    }()
    
    
    
    override func draw(_ rect: CGRect) {
        let topLine = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 0.5))
        UIColor.gray.setStroke()
        topLine.lineWidth = 0.2
        topLine.stroke()
        
        let bottomLine = UIBezierPath(rect: CGRect(x: 0, y: self.frame.size.height - 0.5, width: self.frame.size.width, height: 0.5))
        UIColor.lightGray.setStroke()
        bottomLine.lineWidth = 0.2
        bottomLine.stroke()
    }
    
    override func layoutSubviews() {
        print("****************************layoutSubviews in MiniPlayerView********************")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.setUpSubviews()
//        self.songTitleLabel.text = "핫도그 마시써"
        
        print("****************************init() in MiniPlayerView****************************")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    
    func nextSongButtonHandler()
    {
        NotificationCenter.default.post(name: Notification.Name("nextSongButtonTouched"), object: nil, userInfo: nil)
        print("nextSongButtonHandler touched")
    }
    
    func playOrStopButtonHandler()
    {

        NotificationCenter.default.post(name: Notification.Name("playOrStopButtonTouched"), object: nil, userInfo: nil)
        print("playOrStopButtonHandler touched")
        
    }
    func playerStateDidChange(_ state: State)
    {
        switch state
        {
        case .ready:
            self.playOrstopButton.setImage(#imageLiteral(resourceName: "MusicPlayer_play"), for: UIControlState())
            print("레디")
        case .loading:
            self.playOrstopButton.setImage(#imageLiteral(resourceName: "MusicPlayer_pause"), for: UIControlState())
            print("로딩")
        case .playing:
            self.playOrstopButton.setImage(#imageLiteral(resourceName: "MusicPlayer_pause"), for: UIControlState())
            print("플레잉")
        case .paused, .failed:
            self.playOrstopButton.setImage(#imageLiteral(resourceName: "MusicPlayer_play"), for: UIControlState())
            print("퍼스 풰일")
        }
    }
    
    func updateMiniPlayerCurrent(metaData: Music)
    {
        let imgStr:String = metaData.albumImg
        if let url = URL(string: imgStr)
        {
            self.miniPlayerImageView.sd_setImage(with: url, completed: nil)
        }
        self.songTitleLabel.text = metaData.title
    }

    func miniPlayerButtonHandler()
    {        
        self.delegate?.presentMusicPlayerController()
        print("MiniplayerButton touched")
    }

    
    //init에서 불림
    //MiniPlayerView에 있는 subview들을 셋업한다
    func setUpSubviews()
    {
        self.addSubviews([nextSongButton, miniPlayerImageView, songTitleLabel, miniPlayerButton, playOrstopButton, nextSongButton, visualEffectView])
        

        let side:CGFloat = 45
        let margin:CGFloat = 20
        
        visualEffectView.anchor(top: self.topAnchor, left: self.leftAnchor, right: self.rightAnchor, bottom: nil, topConstant: 2, leftConstant: 0, rightConstant: 0, bottomConstant: 0, width: self.frame.width , height: self.frame.height - 4, centerX: nil, centerY: nil)
        self.sendSubview(toBack: visualEffectView)
        
        miniPlayerImageView.anchor(top: self.topAnchor, left: self.leftAnchor, right: nil, bottom: nil, topConstant: 5, leftConstant: margin, rightConstant: 0, bottomConstant: 0, width: side, height: side, centerX: nil, centerY: nil)
        miniPlayerImageView.layer.cornerRadius = 45 / 10
        
        nextSongButton.anchor(top: self.topAnchor, left: nil, right: self.rightAnchor, bottom: nil, topConstant: 5, leftConstant: 0, rightConstant: margin, bottomConstant: 0, width: side, height: side, centerX: nil, centerY: nil)

        playOrstopButton.anchor(top: self.topAnchor, left: nil, right: self.nextSongButton.leftAnchor, bottom: nil, topConstant: 5, leftConstant: margin, rightConstant: 0, bottomConstant: 0, width: side, height: side, centerX: nil, centerY: nil)
        
        
        songTitleLabel.anchor(top: nil, left: self.miniPlayerImageView.rightAnchor, right: self.playOrstopButton.leftAnchor, bottom: nil, topConstant: 5, leftConstant: margin, rightConstant: 0, bottomConstant: 0, width: -1, height: side / 2, centerX: nil, centerY: self.centerYAnchor)
        
        
        miniPlayerButton.anchor(top: self.topAnchor, left: self.leftAnchor, right: self.rightAnchor, bottom: self.bottomAnchor, topConstant: 0, leftConstant: 0, rightConstant: 0, bottomConstant: 0, width: self.frame.width, height: self.frame.height, centerX: nil, centerY: nil)
    }
    
}

protocol MiniPlayerViewDelegate
{
    func presentMusicPlayerController()
}

