//
//  MiniPlayerView.swift
//  DYMusicPlayer
//
//  Created by Dong Yoon Han on 8/7/17.
//  Copyright © 2017 DY. All rights reserved.
//

import UIKit

class MiniPlayerView: UIView {

    var delegate:MiniPlayerViewDelegate?

    //임시 이미지 바꾸기 위한 플레이버튼 플래그
    var isPlayingMusic:Bool = false

    
    let miniPlayerButton:UIButton = {
        
        let button = UIButton()
        button.addTarget(self, action: #selector(miniPlayerButtonHandler), for: .touchUpInside)
        return button
    }()
    
    let miniPlayerImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "hotdog")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
//        imageView.backgroundColor = .yellow
        return imageView
    }()
    
    let songTitleLabel:UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textAlignment = .left
//        titleLabel.backgroundColor = .blue
        return titleLabel
    }()
    
    
    let playOrstopButton:UIButton = {
        
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "MusicPlayer_play"), for: .normal)
        button.tintColor = .black
//        button.backgroundColor = .red
        button.addTarget(self, action: #selector(playOrStopButtonHandler), for: .touchUpInside)
        return button
    }()
    
    let nextSongButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "MusicPlayer_next"), for: .normal)
        button.tintColor = .black
//        button.backgroundColor = .green
        button.addTarget(self, action: #selector(nextSongButtonHandler), for: .touchUpInside)
        return button
    }()
    
    let visualEffectView:UIVisualEffectView = {
        let blurEffect:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
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

        self.setUpSubviews()
        self.songTitleLabel.text = "핫도그 마시써"
        
        print("****************************init() in MiniPlayerView****************************")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
//        super.init(coder: aDecoder)
//        self.setUpSubviews()
        fatalError("init(coder:) has not been implemented")
    }

    
    func nextSongButtonHandler()
    {
        print("nextSongButtonHandler touched")
        
    }

    
    func playOrStopButtonHandler()
    {

        NotificationCenter.default.post(name: Notification.Name("playOrStopButtonTouched"), object: nil, userInfo: nil)

        if self.isPlayingMusic //노래가 나오고 있을때 --> pause 이미지 ---바꾸기---> play 이미지로
        {
            playOrstopButton.setImage(#imageLiteral(resourceName: "MusicPlayer_play"), for: .normal)
            self.isPlayingMusic = false
        }else // pause 이미지로 바꾸기
        {
            playOrstopButton.setImage(#imageLiteral(resourceName: "MusicPlayer_pause"),for: .normal)
            self.isPlayingMusic = true
        }
        
        
        print("playOrStopButtonHandler touched")
        
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
        self.sendSubview(toBack: visualEffectView)

        let side:CGFloat = 45
        let margin:CGFloat = 20
        let labelWidth:CGFloat = self.frame.width - (margin * 4) - (side * 3)
        
        visualEffectView.anchor(top: self.topAnchor, left: self.leftAnchor, right: self.rightAnchor, bottom: self.bottomAnchor, topConstant: 0, leftConstant: 0, rightConstant: 0, bottomConstant: 0, width: self.frame.width, height: self.frame.height, centerX: self.centerXAnchor, centerY: self.centerYAnchor)
        
        miniPlayerImageView.anchor(top: self.topAnchor, left: self.leftAnchor, right: nil, bottom: self.bottomAnchor, topConstant: 5, leftConstant: margin, rightConstant: 0, bottomConstant: 5, width: side, height: side, centerX: nil, centerY: self.centerYAnchor)
        miniPlayerImageView.layer.cornerRadius = 45 / 10

        songTitleLabel.anchor(top: self.topAnchor, left: self.miniPlayerImageView.rightAnchor, right: nil, bottom: self.bottomAnchor, topConstant: 5, leftConstant: margin, rightConstant: 0, bottomConstant: 5, width: labelWidth, height: side / 2, centerX: nil, centerY: self.centerYAnchor)
        
        playOrstopButton.anchor(top: self.topAnchor, left: self.songTitleLabel.rightAnchor, right: nil, bottom: self.bottomAnchor, topConstant: 5, leftConstant: margin, rightConstant: 0, bottomConstant: 5, width: side, height: side, centerX: nil, centerY: centerYAnchor)
        
        nextSongButton.anchor(top: self.topAnchor, left: self.playOrstopButton.rightAnchor, right: self.rightAnchor, bottom: self.bottomAnchor, topConstant: 5, leftConstant: 0, rightConstant: margin, bottomConstant: 5, width: side, height: side, centerX: nil, centerY: centerYAnchor)
        
        miniPlayerButton.anchor(top: self.topAnchor, left: self.leftAnchor, right: self.rightAnchor, bottom: self.bottomAnchor, topConstant: 0, leftConstant: 0, rightConstant: 0, bottomConstant: 0, width: self.frame.width, height: self.frame.height, centerX: self.centerXAnchor, centerY: self.centerYAnchor)

    }
    
}

protocol MiniPlayerViewDelegate
{
    func presentMusicPlayerController()
}

