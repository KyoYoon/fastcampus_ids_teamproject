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

class MusicPlayerViewController: UIViewController {

    let commandCenter = MPRemoteCommandCenter.shared()
    
//    commandCenter.previousTrackCommand.enabled = true;
//    commandCenter.previousTrackCommand.addTarget(self, action: "previousTrack")
//    
//    commandCenter.nextTrackCommand.enabled = true
//    commandCenter.nextTrackCommand.addTarget(self, action: "nextTrack")
//    
//    commandCenter.playCommand.enabled = true
//    commandCenter.playCommand.addTarget(self, action: "playAudio")
//    
//    commandCenter.pauseCommand.enabled = true
//    commandCenter.pauseCommand.addTarget(self, action: "pauseAudio")
    
    
    var musicPlayer:AVPlayer?
    var isPlayingMusic:Bool = false
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var albumImageView: UIImageView!
    
    @IBOutlet weak var songTitleLB: UILabel!
    @IBOutlet weak var artistLB: UILabel!
    
    @IBOutlet weak var playOrStopButton: UIButton!
    @IBOutlet weak var playerProgressSlider: UISlider!
    @IBOutlet weak var playingProgressLB: UILabel!

    @IBOutlet weak var totalLengthOfSongLB: UILabel!
    
    let blurEffectView:UIVisualEffectView = {
        let effect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: effect)
        return blurView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("MusicPlayerViewController viewWillAppear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("MusicPlayerViewController viewWillDisappear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MusicPlayerViewController.playOrStopButtonHandler), name: Notification.Name("playOrStopButtonTouched"), object: nil)
        
        self.closeButton.tintColor = .lightGray
        
        
        self.albumImageView.image = #imageLiteral(resourceName: "hotdog")
        self.songTitleLB.text = "hotdog 먹고파"
        self.artistLB.text = "그럼 먹어"
        
        self.albumImageView.layer.cornerRadius = self.albumImageView.frame.width / 30
        self.albumImageView.clipsToBounds = true

        blurEffectView.frame = self.view.bounds
        self.view.addSubview(blurEffectView)
        self.view.sendSubview(toBack: blurEffectView)
        
        playerProgressSlider.value = 0.0
        playerProgressSlider.minimumTrackTintColor = .red
        playerProgressSlider.maximumTrackTintColor = .lightGray
        playerProgressSlider.setThumbImage(#imageLiteral(resourceName: "thumb_normal"), for: UIControlState())
        playerProgressSlider.setThumbImage(#imageLiteral(resourceName: "thumb_highlight"), for: .highlighted)
        
//        commandCenter.previousTrackCommand.isEnabled = true;
//        commandCenter.playCommand.addTarget(self, action: #selector(MusicPlayerViewController.playOrStopButtonHandler))
//        
//        commandCenter.nextTrackCommand.isEnabled = true
//        commandCenter.playCommand.addTarget(self, action: #selector(MusicPlayerViewController.playOrStopButtonHandler))
//        
            commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget(self, action: #selector(MusicPlayerViewController.playOrStopButtonHandler))
        
            commandCenter.pauseCommand.isEnabled = true
            commandCenter.pauseCommand.addTarget(self, action: #selector(MusicPlayerViewController.playOrStopButtonHandler))
        
//        loadAssetFromFile(stringURL: "1.mp3")
        let url:String = "https://s3.ap-northeast-2.amazonaws.com/weather-sound-test-s3-bucket/static/musics/189d09e4dda60e2fdb355a2b661a7c4e2ac5a8b959de878ff16a2188b5618255.mp3"
        loadAssetFromFile(stringURL: url)

        print("MusicPlayerViewController viewDidLoad")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    @IBAction func closeButtonTouched(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func previousButtonTouched(_ sender: UIButton) {
        print("previousButtonTouched touched")
    }
    
    @IBAction func playOrStopButtonTouched(_ sender: UIButton) {
        
//        if self.isPlayingMusic //노래가 나오고 있을때 --> pause로------> play 이미지로
//        {
//            musicPlayer?.pause()
//            sender.setImage(#imageLiteral(resourceName: "MusicPlayer_play"), for: .normal)
//        }else // pause 이미지로 바꾸기
//        {
//            musicPlayer?.play()
//            sender.setImage(#imageLiteral(resourceName: "MusicPlayer_pause"),for: .normal)
//        }
//        self.isPlayingMusic = !self.isPlayingMusic
        playOrStopButtonHandler()
        print("playOrStopButtonHandler touched in MusicPlayerViewController")
    }
    
    func playOrStopButtonHandler()
    {
        if self.isPlayingMusic //노래가 나오고 있을때 --> pause로------> play 이미지로
        {
            musicPlayer?.pause()
            playOrStopButton.setImage(#imageLiteral(resourceName: "MusicPlayer_play"), for: .normal)
        }else // pause 이미지로 바꾸기
        {
            
            
            musicPlayer?.play()
            playOrStopButton.setImage(#imageLiteral(resourceName: "MusicPlayer_pause"),for: .normal)
        }
        self.isPlayingMusic = !self.isPlayingMusic
        print("helloooooooooooooooooooo")
    }

    

    @IBAction func nextButtonTouched(_ sender: UIButton) {
        print("nextButtonTouched touched")

    }
    
    @IBAction func playerProgressSliderValueChanged(_ sender: UISlider) {
        guard let item = musicPlayer?.currentItem else { return }
        let newPosition = Double(sender.value) * item.duration.seconds
        
        //        musicPlayer?.seek(to: CMTime(value: Int64(newPosition), timescale: 1))
        musicPlayer?.seek(to: CMTime(seconds: newPosition, preferredTimescale: 1000))
                musicPlayer?.playImmediately(atRate: 1.0)
    }
    
    @IBAction func playerProgressSliderTapGesture(_ sender: UITapGestureRecognizer) {
        
        let pointTapped: CGPoint = sender.location(in: self.view)
        
        let positionOfSlider: CGPoint = playerProgressSlider.frame.origin
        let widthOfSlider: CGFloat = playerProgressSlider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(playerProgressSlider.maximumValue) / widthOfSlider)
        
        playerProgressSlider.setValue(Float(newValue), animated: true)
        
        guard let item = musicPlayer?.currentItem else { return }
        let newPosition = Double(playerProgressSlider.value) * item.duration.seconds
        
        //        player.seek(to: CMTime(value: Int64(newPosition), timescale: 1))
        musicPlayer?.seek(to: CMTime(seconds: newPosition, preferredTimescale: 1000))
    }
    
    func loadAssetFromFile(stringURL: String)
    {
//        guard let dot = stringURL.range(of: ".") else { return }
//        let fileParts = (resource: stringURL.substring(to: dot.lowerBound), extension: stringURL.substring(from: dot.upperBound))
//        if let fileURL = Bundle.main.url(forResource: fileParts.resource, withExtension: fileParts.extension)
//        {
//            let asset = AVURLAsset(url: fileURL)
            let url = URL(string: stringURL)
            let asset = AVURLAsset(url: url!)
            let playerItem = AVPlayerItem(asset: asset)
            self.musicPlayer = AVPlayer(playerItem: playerItem)
//            self.musicPlayer?.rate = 1.0
//
//                        playerItem.addObserver(self, forKeyPath: "status", options: .new, context: &kvoContext)
            musicPlayer?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
            
            let interval = CMTime(value: 1, timescale: 2)
            
            musicPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
                
                let seconds = CMTimeGetSeconds(progressTime)
                let secondsString = String(format: "%02d", Int(seconds.truncatingRemainder(dividingBy: 60)))
                let minutesString = String(format: "%01d", Int(seconds / 60))
                
                self.playingProgressLB.text = "\(minutesString):\(secondsString)"
                
                //lets move the slider thumb
                if let duration = self.musicPlayer?.currentItem?.duration {
                    let durationSeconds = CMTimeGetSeconds(duration)
                    
                    self.playerProgressSlider.value = Float(seconds / durationSeconds)
                }
            })
//            NotificationCenter.default.addObserver(self, selector: #selector(self.playFinished), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: self.musicPlayer?.currentItem!)
//        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //this is when the player is ready and rendering frames
        if let key = keyPath
        {
            switch key
            {
            case "currentItem.loadedTimeRanges":
                isPlayingMusic = true
                if let duration = musicPlayer?.currentItem?.duration
                {
                    let seconds = CMTimeGetSeconds(duration)
                    
                    let secondsText = Int(seconds) % 60
                    let minutesText = String(format: "%02d", Int(seconds) / 60)
                    totalLengthOfSongLB.text = "\(minutesText):\(secondsText)"
                }
            default:
                break
            }
        }
    }
    
//    func playFinished(send: NotificationCenter){
//        self.removeObserver()
//    }
//    
//    func removeObserver(){
//        self.musicPlayer?.currentItem?.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges")
//    }
    
}
