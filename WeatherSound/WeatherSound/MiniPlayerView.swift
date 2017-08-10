//
//  MiniPlayerView.swift
//  DYMusicPlayer
//
//  Created by Dong Yoon Han on 8/7/17.
//  Copyright © 2017 DY. All rights reserved.
//

import UIKit

class MiniPlayerView: UIView {

    var musicPlayerVC:MusicPlayerViewController?
    
    let miniPlayerButton:UIButton = {
        
        let button = UIButton()
        button.backgroundColor = UIColor.red
        //
        
        button.addTarget(self, action: #selector(miniPlayerButtonHandler), for: .touchUpInside)
        return button
    }()
    
    let miniPlayerImageView:UIImageView = {
        let imageView = UIImageView()
        
        return imageView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(miniPlayerButton)
        miniPlayerButton.anchor(top: self.topAnchor, left: self.leftAnchor, right: self.rightAnchor, bottom: self.bottomAnchor, topConstant: 0, leftConstant: 0, rightConstant: 0, bottomConstant: 0, width: self.frame.width, height: self.frame.height, centerX: self.centerXAnchor, centerY: self.centerYAnchor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func miniPlayerButtonHandler()
    {
        guard let musicPlayerVC = self.musicPlayerVC else { return }
        
        musicPlayerVC.present(musicPlayerVC, animated: true, completion: nil)
        print("MiniplayerButton touched")
    }
    
}


