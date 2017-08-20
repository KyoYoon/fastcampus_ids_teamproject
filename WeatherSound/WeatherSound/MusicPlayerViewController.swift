//
//  MusicPlayerViewController.swift
//  DYMusicPlayer
//
//  Created by Dong Yoon Han on 8/7/17.
//  Copyright © 2017 DY. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import SDWebImage

class MusicPlayerViewController: UIViewController, WSPlayerDelegate {

    var musicPlayer: WSPlayer?
    var delegate: MusicPlayerViewControllerDelegate?
    
    @IBOutlet weak var closeButton: UIButton!
    
    let albumCoverView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "hotdog") // default image
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    
    let songTitleLabel:UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "song title label"
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    let artistLabel:UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "artist label"
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    let musicProgressSlider:UISlider = {
        
        let progressSlider = UISlider()
        progressSlider.value = 0.0
        progressSlider.minimumTrackTintColor = .red
        progressSlider.maximumTrackTintColor = .lightGray
        progressSlider.setThumbImage(#imageLiteral(resourceName: "thumb_normal"), for: UIControlState())
        progressSlider.setThumbImage(#imageLiteral(resourceName: "thumb_highlight"), for: .highlighted)
        progressSlider.addTarget(self, action: #selector(playerProgressSliderValueChanged), for: .valueChanged)
        return progressSlider
    }()
    
    let currentProgressLB:UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "0:00"
        titleLabel.font = UIFont.systemFont(ofSize: 11)
        titleLabel.textColor = .lightGray
        titleLabel.textAlignment = .left
        return titleLabel
    }()
    
    let musicDurationLB:UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "11:11"
        titleLabel.font = UIFont.systemFont(ofSize: 11)
        titleLabel.textColor = .lightGray
        titleLabel.textAlignment = .right
        return titleLabel
    }()
    
    let addToMyListButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "MusicPlayer_add"), for: .normal)
        button.tintColor = .black
//        button.addTarget(self, action: #selector(addToMyListButtonHandler), for: .touchUpInside)
        return button
    }()
    
    
    let previousSongButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "MusicPlayer_previous"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(previousSongButtonHandler), for: .touchUpInside)
        return button
    }()
    
    let playOrStopButton:UIButton = {
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
    

//    let blurEffectView:UIVisualEffectView = {
//        let effect = UIBlurEffect(style: .light)
//        let blurView = UIVisualEffectView(effect: effect)
//        return blurView
//    }()
    
    @IBAction func closeButtonTouched(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("MusicPlayerViewController viewWillAppear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("MusicPlayerViewController viewWillDisappear")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadWSPlayerItems()
    {
        self.musicPlayer = WSPlayer(delegate: self, items: DataCenter.shared.playItems)
        print("self.musicPlayer = WSPlayer(delegate: self, items: DataCenter.shared.playItems) ")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // begin receiving remote events
        UIApplication.shared.beginReceivingRemoteControlEvents()
        print("MusicPlayerViewController!!!******************************************************")
        
        NotificationCenter.default.addObserver(self, selector: #selector(playOrStopButtonHandler), name: Notification.Name("playOrStopButtonTouched"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(nextSongButtonHandler), name: Notification.Name("nextSongButtonTouched"), object: nil)
    
        setupUI()
        
    }
    
    func playSongSelectedFromMain(_ notification:Notification)
    {
        print("playSongSelectedFromMain")
        if let userInfo = notification.userInfo
        {
            if let selectedIndex = userInfo["SongSelectedRowAt"] as? Int
            {
                print("SongSelectedRowAtSongSelectedRowAtSongSelectedRowAt")
                self.musicPlayer?.play(atIndex: selectedIndex)
            }
        }
    }
    
    func setupUI()
    {
        self.closeButton.tintColor = .lightGray

//        blurEffectView.frame = self.view.bounds
//        self.view.addSubview(blurEffectView)
//        self.view.sendSubview(toBack: blurEffectView)
        
        let defaultWidth = self.view.frame.width - 40
        let defaultMargin: CGFloat = 20
        
        self.view.addSubviews([albumCoverView, songTitleLabel, artistLabel, musicProgressSlider, currentProgressLB, musicDurationLB, previousSongButton, playOrStopButton, nextSongButton])
        
        self.albumCoverView.anchor(top: self.closeButton.bottomAnchor, left: nil, right: nil, bottom: nil, topConstant: defaultMargin, leftConstant: 0, rightConstant: 0, bottomConstant: 0, width: defaultWidth, height: defaultWidth, centerX: self.view.centerXAnchor, centerY: nil)
        self.albumCoverView.layer.cornerRadius = defaultWidth / 20
        
        self.songTitleLabel.anchor(top: self.albumCoverView.bottomAnchor, left: nil, right: nil, bottom: nil, topConstant: defaultMargin, leftConstant: 0, rightConstant: 0, bottomConstant: 0, width: defaultWidth - 50, height: 30, centerX: self.view.centerXAnchor, centerY: nil)
        
        self.artistLabel.anchor(top: self.songTitleLabel.bottomAnchor, left: nil, right: nil, bottom: nil, topConstant: 0, leftConstant: 0, rightConstant: 0, bottomConstant: 0, width: defaultWidth - 50, height: 30, centerX: self.view.centerXAnchor, centerY: nil)
        
        self.musicProgressSlider.anchor(top: self.artistLabel.bottomAnchor, left: nil, right: nil, bottom: nil, topConstant: 20, leftConstant: 0, rightConstant: 0, bottomConstant: 0, width: defaultWidth, height: 30, centerX: self.view.centerXAnchor, centerY: nil)
        
        self.currentProgressLB.anchor(top: self.musicProgressSlider.bottomAnchor, left: self.musicProgressSlider.leftAnchor, right: nil, bottom: nil, topConstant: -5, leftConstant: 0, rightConstant: 0, bottomConstant: 0, width: defaultWidth / 8, height: 20, centerX: nil, centerY: nil)
        
        self.musicDurationLB.anchor(top: self.musicProgressSlider.bottomAnchor, left: nil, right: self.musicProgressSlider.rightAnchor, bottom: nil, topConstant: -5, leftConstant: 0, rightConstant: 0, bottomConstant: 0, width: defaultWidth / 8, height: 20, centerX: nil, centerY: nil)
        
        self.playOrStopButton.anchor(top: self.musicProgressSlider.bottomAnchor, left: nil, right: nil, bottom: nil, topConstant: defaultMargin , leftConstant: 0, rightConstant: 0, bottomConstant: 0, width: defaultWidth / 3, height: 50, centerX: self.view.centerXAnchor, centerY: nil)
        
        self.previousSongButton.anchor(top: self.musicProgressSlider.bottomAnchor, left: nil, right: self.playOrStopButton.leftAnchor, bottom: nil, topConstant: defaultMargin , leftConstant: 0, rightConstant: 0, bottomConstant: 0, width: defaultWidth / 3, height: 50, centerX: nil, centerY: nil)
        
        self.nextSongButton.anchor(top: self.musicProgressSlider.bottomAnchor, left: self.playOrStopButton.rightAnchor, right: nil, bottom: nil, topConstant: defaultMargin , leftConstant: 0, rightConstant: 0, bottomConstant: 0, width: defaultWidth / 3, height: 50, centerX: nil, centerY: nil)
        
        let gestureRec = UITapGestureRecognizer(target: self, action:  #selector(progressSliderTapGesture))
        musicProgressSlider.addGestureRecognizer(gestureRec)
    }

    // MARK: - ************************* WSPlayerDelegate *************************
    
    func wsPlayerDidLoadItem(_ WSPlayer: WSPlayer, item: WSPlayItem) {
        print("didLoad: \(item.URL.lastPathComponent)")
    }
    
    func wsPlayerPlaybackProgressDidChange(_ WSPlayer: WSPlayer) {
        
        if let currentTime = WSPlayer.currentItem?.currentTime, let duration = WSPlayer.currentItem?.meta.duration {
            let value = Float(currentTime / duration)
            musicProgressSlider.value = value
            populateLabelWithTime(currentProgressLB, time: currentTime)
            populateLabelWithTime(musicDurationLB, time: duration)
        } else {
            resetUI()
        }
    }
    
    func wsPlayerStateDidChange(_ WSPlayer: WSPlayer) {
        
//        UIView.animate(withDuration: 0.3, animations: { () -> Void in
//            self.indicator.alpha = jukebox.state == .loading ? 1 : 0
//            self.playPauseButton.alpha = jukebox.state == .loading ? 0 : 1
//            self.playPauseButton.isEnabled = jukebox.state == .loading ? false : true
//        })
        let changedState = WSPlayer.state
        
        if changedState == .ready
        {
            playOrStopButton.setImage(#imageLiteral(resourceName: "MusicPlayer_play"), for: UIControlState())
        } else if changedState == .loading
        {
            self.playOrStopButton.setImage(#imageLiteral(resourceName: "MusicPlayer_pause"), for: UIControlState())

        } else //.playing, .paused, .failed
        {
//            volumeSlider.value = player.volume
            let image: UIImage
            switch WSPlayer.state
            {
            case .playing, .loading:
                image = #imageLiteral(resourceName: "MusicPlayer_pause")

            case .paused, .failed, .ready:
                image = #imageLiteral(resourceName: "MusicPlayer_play")
            }
            playOrStopButton.setImage(image, for: UIControlState())
        }

        self.delegate?.playerStateDidChange(changedState)
        print("state changed to \(WSPlayer.state)")

    }
    
    func wsPlayerDidUpdateMetadata(_ WSPlayer: WSPlayer, forItem: WSPlayItem)
    {
        print("Item updated:\n\(forItem)")
    }
    
    func updateCurrentPlay(metaData: Music)
    {
        let imgStr:String = metaData.albumImg
        if let url = URL(string: imgStr)
        {
            self.albumCoverView.sd_setImage(with: url, completed: nil)
        }
        self.songTitleLabel.text = metaData.title
        self.artistLabel.text = metaData.artist
        
        self.delegate?.updateMiniPlayerCurrent(metaData: metaData)
    }
/***********************************************************************************/

    override func remoteControlReceived(with event: UIEvent?)
    {
        guard let musicPlayer = self.musicPlayer else { return }
        if event?.type == .remoteControl
        {
            switch event!.subtype
            {
            case .remoteControlPlay :
                musicPlayer.play()
            case .remoteControlPause :
                musicPlayer.pause()
            case .remoteControlNextTrack :
                musicPlayer.playNext()
            case .remoteControlPreviousTrack:
                musicPlayer.playPrevious()
            case .remoteControlTogglePlayPause:
                if musicPlayer.state == .playing
                {
                    musicPlayer.pause()
                } else
                {
                    musicPlayer.play()
                }
            default:
                break
            }
        }
    }
    
    
    
    func addToMyListButtonHandler()
    {
        print("addToMyListButtonHandler touched")
    }
    
    func previousSongButtonHandler()
    {
        if let time = musicPlayer?.currentItem?.currentTime, time > 5.0 || musicPlayer?.playIndex == 0
        {
            musicPlayer?.replayCurrentItem()
        } else {
            musicPlayer?.playPrevious()
        }
        print("previousSongButtonHandler touched")
    }
    
    func nextSongButtonHandler()
    {
        
        musicPlayer?.playNext()
        print("nextSongButtonHandler touched")
    }
    
    func playOrStopButtonHandler()
    {
        if let state = musicPlayer?.state
        {
            switch state//musicPlayer?.state
            {
            case .ready :
                musicPlayer?.play(atIndex: 0)
            case .playing :
                musicPlayer?.pause()
            case .paused :
                musicPlayer?.play()
            default:
                musicPlayer?.stop()
            }
        }
    }

    
    func playerProgressSliderValueChanged(_ sender: UISlider)
    {
        if let duration = musicPlayer?.currentItem?.meta.duration
        {
            musicPlayer?.seek(toSecond: Int(Double(musicProgressSlider.value) * duration))
        }
    }
    
    func progressSliderTapGesture(_ sender: UITapGestureRecognizer)
    {
        
        let pointTapped: CGPoint = sender.location(in: self.view)
        
        let positionOfSlider: CGPoint = musicProgressSlider.frame.origin
        let widthOfSlider: CGFloat = musicProgressSlider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(musicProgressSlider.maximumValue) / widthOfSlider)
        
        musicProgressSlider.setValue(Float(newValue), animated: true)
        
        if let duration = musicPlayer?.currentItem?.meta.duration {
            musicPlayer?.seek(toSecond: Int(Double(musicProgressSlider.value) * duration))
        }
    }
    
    
    func populateLabelWithTime(_ label : UILabel, time: Double) {
        let minutes = Int(time / 60)
        let seconds = Int(time) - minutes * 60
        
        label.text = String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
    }
    
    func resetUI()
    {
        currentProgressLB.text = "0:00"
        musicDurationLB.text = "00:00"
        musicProgressSlider.value = 0.0
    }

}

protocol MusicPlayerViewControllerDelegate
{
    func playerStateDidChange(_ state: State)
    func updateMiniPlayerCurrent(metaData: Music)
}
