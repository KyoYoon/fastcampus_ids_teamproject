//
//  WSPlayer.swift
//  WeatherSound
//
//  Created by Dong Yoon Han on 8/13/17.
//  Copyright © 2017 정교윤. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

protocol WSPlayerDelegate: class
{
    func wsPlayerStateDidChange(_ WSPlayer : WSPlayer)
    func wsPlayerPlaybackProgressDidChange(_ WSPlayer : WSPlayer)
    func wsPlayerDidLoadItem(_ WSPlayer : WSPlayer, item : WSPlayItem)
    func wsPlayerDidUpdateMetadata(_ WSPlayer : WSPlayer, forItem: WSPlayItem)
    func updateCurrentPlay(metaData: Music)
}

public enum State: Int, CustomStringConvertible
{
    case ready = 0
    case playing
    case paused
    case loading
    case failed
    
    public var description: String
    {
        get{
            switch self
            {
            case .ready:
                return "Ready"
            case .playing:
                return "Playing"
            case .failed:
                return "Failed"
            case .paused:
                return "Paused"
            case .loading:
                return "Loading"
            }
        }
    }
}

open class WSPlayer : NSObject, WSPlayItemDelegate
{

//    var isPlayingMusic:Bool = false

    // MARK:- Properties -
    fileprivate var player                       :   AVPlayer?
    fileprivate var progressObserver             :   Any!
    fileprivate var backgroundIdentifier         =   UIBackgroundTaskInvalid
    fileprivate(set) weak var delegate    :   WSPlayerDelegate?
    
    fileprivate (set) open var playIndex       =   0 //현재 플레이 되는?될? 인덱스
//    fileprivate (set) var queuedItems     :   [WSPlayItem]!
    fileprivate (set) var queuedItems     :   [WSPlayItem] = []

    fileprivate (set) open var state           =   State.ready {
        didSet {
            delegate?.wsPlayerStateDidChange(self)
        }
    }

    // MARK:- Computed properties -
    
//    open var volume: Float{
//        get {
//            return player?.volume ?? 0
//        }
//        set {
//            player?.volume = newValue
//        }
//    }
    
    var currentItem: WSPlayItem? {
        guard playIndex >= 0 && playIndex < queuedItems.count else {
            return nil
        }
        return queuedItems[playIndex]
    }
    
    fileprivate var playerOperational: Bool {
        return player != nil && currentItem != nil
    }

    // MARK:- Initializer -
    
    /**
     Create an instance with a delegate and a list of items without loading their assets.
     
     - parameter delegate: WSPlayer delegate
     - parameter items:    array of items to be added to the play queue
     
     - returns: WSPlayer instance
     */
    init?(delegate: WSPlayerDelegate? = nil)//, items: [WSPlayItem])
    {
        self.delegate = delegate
        super.init()
        
        do {
            try configureAudioSession()
        } catch {
            print("[ Error] \(error)")
            return nil
        }
//        assignQueuedItems(items)
        configureObservers()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    
    /******************************************************************************************/
    // Mark: - WSPlayer Public Methods
    
    /**
     Starts item playback.
     */
    public func play() {
        play(atIndex: playIndex)
    }
    
    /**
     Plays the item indicated by the passed index
     
     - parameter index: index of the item to be played
     */
    public func play(atIndex index: Int)
    {
        guard index < queuedItems.count && index >= 0 else {return}
        
        DispatchQueue.main.async {
            self.delegate?.updateCurrentPlay(metaData: self.queuedItems[index].meta)
        }
        
        configureBackgroundAudioTask()
        
        if queuedItems[index].playerItem != nil && playIndex == index
        {
            resumePlayback()
        } else
        {
            if let item = currentItem?.playerItem
            {
                unregisterForPlayToEndNotification(withItem: item)
            }
            playIndex = index
            
            if let asset = queuedItems[index].playerItem?.asset
            {
                playCurrentItem(withAsset: asset)
            } else
            {
                loadPlaybackItem()
            }
            preloadNextAndPrevious(atIndex: playIndex)
        }
//        self.delegate?.updateCurrentPlay(metaData: (self.currentItem?.meta)!)
        updateInfoCenter()
    }
    
    /**
     Pauses the playback.
     */
    public func pause()
    {
        stopProgressTimer()
        player?.pause()
        state = .paused
    }
    
    /**
     Stops the playback.
     */
    public func stop()
    {
        invalidatePlayback()
        state = .ready
        UIApplication.shared.endBackgroundTask(backgroundIdentifier)
        backgroundIdentifier = UIBackgroundTaskInvalid
    }
    
    /**
     Starts playback from the beginning of the queue.
     */
    public func replay()
    {
        guard playerOperational else {return}
        stopProgressTimer()
        seek(toSecond: 0)
        play(atIndex: 0)
    }
    
    /**
     Plays the next item in the queue.
     */
    public func playNext()
    {
        guard playerOperational else {return}
        play(atIndex: playIndex + 1)
    }
    
    /**
     Restarts the current item or plays the previous item in the queue
     */
    public func playPrevious()
    {
        guard playerOperational else {return}
        play(atIndex: playIndex - 1)
    }
    
    /**
     Restarts the playback for the current item
     */
    public func replayCurrentItem()
    {
        guard playerOperational else {return}
        seek(toSecond: 0, shouldPlay: true)
    }
    
    /**
     Seeks to a certain second within the current AVPlayerItem and starts playing
     
     - parameter second: the second to seek to
     - parameter shouldPlay: pass true if playback should be resumed after seeking
     */
    public func seek(toSecond second: Int, shouldPlay: Bool = false)
    {
        guard let player = player, let item = currentItem else {return}
        
        player.seek(to: CMTimeMake(Int64(second), 1))
        item.update()
        if shouldPlay
        {
            player.play()
            
            if state != .playing
            {
                state = .playing
            }
        }
        delegate?.wsPlayerPlaybackProgressDidChange(self)
//        DispatchQueue.main.async {
//            self.updateInfoCenter()
//        }
    }
    
    /**
     Appends and optionally loads an item
     
     - parameter item:            the item to be appended to the play queue
     - parameter loadingAssets:   pass true to load item's assets asynchronously
     */
    func append(item: WSPlayItem, loadingAssets: Bool)
    {
        queuedItems.append(item)
        item.delegate = self
        if loadingAssets
        {
            item.loadPlayerItem()
        }
    }
    
    /**
     Removes an item from the play queue
     
     - parameter item: item to be removed
     */
    func remove(item: WSPlayItem)
    {
        if let index = queuedItems.index(of: item)
        {
            queuedItems.remove(at: index)
        }
    }
    
    /**
     Removes all items from the play queue matching the URL
     
     - parameter url: the item URL
     */
    public func removeItems(withURL url : URL)
    {
        let indexes = queuedItems.indexesOf({$0.URL as URL == url})
        for index in indexes
        {
            queuedItems.remove(at: index)
        }
    }

/*****************************************************************************************/
    
    
    // MARK:- WSPlayItemDelegate -
    
    func wsPlayItemDidFail(_ item: WSPlayItem)
    {
        stop()
        state = .failed
    }
    
    func wsPlayItemDidUpdate(_ item: WSPlayItem)
    {
        guard let item = currentItem else {return}
        updateInfoCenter()
        self.delegate?.wsPlayerDidUpdateMetadata(self, forItem: item)
        print("아이템!!!!!: ", item.meta.artist)
    }
    
    func wsPlayItemDidLoadPlayerItem(_ item: WSPlayItem)
    {
        delegate?.wsPlayerDidLoadItem(self, item: item)
        let index = queuedItems.index{$0 === item}
        print("index assigned in wsPlayItemDidLoadPlayerItem: ", index!)
        print("self.playIndex in WSPlayer : ", self.playIndex)
        
        guard let playItem = item.playerItem //AVPlayerItem
            , state == .loading && playIndex == index else {return}
        
        registerForPlayToEndNotification(withItem: playItem)
        startNewPlayer(forItem: playItem)
    }

    // MARK:- Private methods -
    
    // MARK: Playback
    
    fileprivate func updateInfoCenter()
    {
        guard let item = currentItem else {return}
        
        let title = item.meta.title ?? item.URL.lastPathComponent
        let currentTime = item.currentTime ?? 0
        let duration = item.meta.duration ?? 0
        let trackNumber = playIndex
        let trackCount = queuedItems.count
        
        var nowPlayingInfo : [String : Any] =
            [
                MPMediaItemPropertyPlaybackDuration : duration as Any,
                MPMediaItemPropertyTitle : title as AnyObject,
                MPNowPlayingInfoPropertyElapsedPlaybackTime : currentTime as Any,
                MPNowPlayingInfoPropertyPlaybackQueueCount :trackCount as Any,
                MPNowPlayingInfoPropertyPlaybackQueueIndex : trackNumber as Any,
                MPMediaItemPropertyMediaType : MPMediaType.anyAudio.rawValue as Any,
                MPNowPlayingInfoPropertyPlaybackRate: NSNumber(value: 1.0 as Float)
            ]

        nowPlayingInfo[MPMediaItemPropertyArtist] = item.meta.artist
        
        if let album = item.meta.albumTitle
        {
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album as Any?
        }
        
        if let imgStr = currentItem?.meta.albumImg
        {

            if let url = URL(string: imgStr), let data = try? Data(contentsOf: url), let artwork = UIImage(data: data)
            {
                nowPlayingInfo[MPMediaItemPropertyArtwork] =  MPMediaItemArtwork(boundsSize: artwork.size, requestHandler: { (_) -> UIImage in
                    return artwork
                })
            }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    fileprivate func playCurrentItem(withAsset asset: AVAsset)
    {
        self.state = .ready
        queuedItems[playIndex].refreshPlayerItem(withAsset: asset)
        startNewPlayer(forItem: queuedItems[playIndex].playerItem!)
        guard let playItem = queuedItems[playIndex].playerItem else {return}
        registerForPlayToEndNotification(withItem: playItem)
    }
    
    fileprivate func resumePlayback()
    {
        if state != .playing
        {
            startProgressTimer()
            if let player = player
            {
                player.play()
            } else
            {
                currentItem!.refreshPlayerItem(withAsset: currentItem!.playerItem!.asset)
                startNewPlayer(forItem: currentItem!.playerItem!)
            }
            state = .playing
        }
    }
    
    fileprivate func invalidatePlayback(shouldResetIndex resetIndex: Bool = true)
    {
        stopProgressTimer()
        player?.pause()
        player = nil
        
        if resetIndex
        {
            playIndex = 0
        }
    }
    
    fileprivate func startNewPlayer(forItem item : AVPlayerItem)
    {
        invalidatePlayback(shouldResetIndex: false)
        player = AVPlayer(playerItem: item)
        player?.allowsExternalPlayback = false
        startProgressTimer()
        seek(toSecond: 0, shouldPlay: true)
        updateInfoCenter()
    }
    
    // MARK: Items related
    
    fileprivate func assignQueuedItems (_ items: [WSPlayItem])
    {
        queuedItems = items
        for item in queuedItems
        {
            print("assignQueuedItems: ", item.meta.title)
            item.delegate = self
        }
    }
    
    fileprivate func loadPlaybackItem()
    {
        guard playIndex >= 0 && playIndex < queuedItems.count else
        {
            return
        }
        
        stopProgressTimer()
        player?.pause()
        queuedItems[playIndex].loadPlayerItem()
        state = .loading
    }
    
    fileprivate func preloadNextAndPrevious(atIndex index: Int)
    {
        guard !queuedItems.isEmpty else {return}
        
        if index - 1 >= 0
        {
            queuedItems[index - 1].loadPlayerItem()
        }
        
        if index + 1 < queuedItems.count
        {
            queuedItems[index + 1].loadPlayerItem()
        }
    }
    
    // MARK: Progress tracking
    
    fileprivate func startProgressTimer(){
        guard let player = player , player.currentItem?.duration.isValid == true else {return}
        progressObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.05, Int32(NSEC_PER_SEC)), queue: nil, using: { [unowned self] (time : CMTime) -> Void in
            self.timerAction()
        }) as Any!
    }
    
    fileprivate func stopProgressTimer()
    {
        guard let player = player, let observer = progressObserver else { return }
        player.removeTimeObserver(observer)
        progressObserver = nil
    }
    
    // MARK: Configurations
    
    fileprivate func configureBackgroundAudioTask()
    {
        backgroundIdentifier =  UIApplication.shared.beginBackgroundTask (expirationHandler: { () -> Void in
            UIApplication.shared.endBackgroundTask(self.backgroundIdentifier)
            self.backgroundIdentifier = UIBackgroundTaskInvalid
        })
    }
    
    fileprivate func configureAudioSession() throws
    {
        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try AVAudioSession.sharedInstance().setMode(AVAudioSessionModeDefault)
        try AVAudioSession.sharedInstance().setActive(true)
    }
    
    // 예외처리: VPlayerItemPlaybackStalled, AVAudioSessionInterruption
    fileprivate func configureObservers()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(WSPlayer.handleStall), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionInterruption), name: NSNotification.Name.AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
    }
    
    // MARK:- Notifications -
    
    func handleAudioSessionInterruption(_ notification : Notification)
    {
        guard let userInfo = notification.userInfo as? [String: AnyObject] else { return }
        guard let rawInterruptionType = userInfo[AVAudioSessionInterruptionTypeKey] as? NSNumber else { return }
        guard let interruptionType = AVAudioSessionInterruptionType(rawValue: rawInterruptionType.uintValue) else { return }
        
        switch interruptionType
        {
        case .began: //interruption started
            self.pause()
        case .ended: //interruption ended
            if let rawInterruptionOption = userInfo[AVAudioSessionInterruptionOptionKey] as? NSNumber
            {
                let interruptionOption = AVAudioSessionInterruptionOptions(rawValue: rawInterruptionOption.uintValue)
                if interruptionOption == AVAudioSessionInterruptionOptions.shouldResume
                {
                    self.resumePlayback()
                }
            }
        }
    }
    
    func handleStall()
    {
        player?.pause()
        player?.play()
    }
    
    func playerItemDidPlayToEnd(_ notification : Notification)
    {
        if playIndex >= queuedItems.count - 1
        {
            stop()
        } else
        {
            play(atIndex: playIndex + 1)
        }
    }
    
    func timerAction()
    {
        guard player?.currentItem != nil else {return}
        currentItem?.update()
        guard currentItem?.currentTime != nil else {return}
        delegate?.wsPlayerPlaybackProgressDidChange(self)
        self.updateInfoCenter()
    }
    
    fileprivate func registerForPlayToEndNotification(withItem item: AVPlayerItem)
    {
        NotificationCenter.default.addObserver(self, selector: #selector(WSPlayer.playerItemDidPlayToEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
    }
    
    fileprivate func unregisterForPlayToEndNotification(withItem item : AVPlayerItem)
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
    }

}


private extension Collection
{
    func indexesOf(_ predicate: (Iterator.Element) -> Bool) -> [Int]
    {
        var indexes = [Int]()
        for (index, item) in enumerated()
        {
            if predicate(item)
            {
                indexes.append(index)
            }
        }
        return indexes
    }
}

private extension CMTime
{
    var isValid : Bool { return (flags.intersection(.valid)) != [] }
}


