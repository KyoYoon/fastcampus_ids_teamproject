//
//  MusicPlayerViewController.swift
//  DYMusicPlayer
//
//  Created by Dong Yoon Han on 8/7/17.
//  Copyright © 2017 DY. All rights reserved.
//

import UIKit

class MusicPlayerViewController: UIViewController {

    let albumImageView:UIImageView = {
    
        let imageView = UIImageView()
        return imageView
    }()

    let musicProgressView:UIProgressView = {
        
        let progressView = UIProgressView()
        
        return progressView
    }()
    
    let playOrstopButton:UIButton = {
        let button = UIButton()

       return button
    }()
    
    let songTitleLabel:UILabel = {
        let titleLabel = UILabel()
        return titleLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    


}
