//
//  WSPlayItem.swift
//  WeatherSound
//
//  Created by Dong Yoon Han on 8/14/17.
//  Copyright © 2017 정교윤. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer


protocol WSPlayItemDelegate : class
{
    func wsPlayItemDidLoadPlayerItem(_ item: WSPlayItem)
    func wsPlayItemDidUpdate(_ item: WSPlayItem)
    func wsPlayItemDidFail(_ item: WSPlayItem)
}


class WSPlayItem : NSObject
{
//    var metaData:Music?
    
    // MARK:- Properties
    //    let identifier: String
    var delegate: WSPlayItemDelegate?
    fileprivate var didLoad = false
    //    open  var localTitle: String?
    open  let URL: URL
    
    fileprivate(set) open var playerItem: AVPlayerItem?
    fileprivate (set) open var currentTime: Double?
    fileprivate(set) open var meta: Music// = Music()
    
    fileprivate var timer: Timer?
    fileprivate let observedValue:String = "timedMetadata"
    
    // MARK:- Initializer -
    
    /**
     Create an instance with an URL and local title
     
     - parameter URL: local or remote URL of the audio file
     - parameter localTitle: an optional title for the file
     
     - returns: Item instance
     */
    public required init(URL : URL, musicItem: Music)
    {
        self.URL = URL
        self.meta = musicItem
        super.init()
        configureMetadata()
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        guard change?[NSKeyValueChangeKey(rawValue:"name")] != nil else
        {
            delegate?.wsPlayItemDidFail(self)
            return
        }
        
        if let key = keyPath
        {
            switch key
            {
            case observedValue:
                if let item = playerItem , item === object as? AVPlayerItem
                {
                    guard let metadata = item.timedMetadata else { return }
                    for item in metadata
                    {
                        switch item.commonKey
                        {
                        case "albumName"? :
                            self.meta.albumTitle = item.value as? String
                        default :
                            break
                        }
                    }
                }
                scheduleNotification()
            default:
                break
            }
        }
    }
    
    deinit {
        playerItem?.removeObserver(self, forKeyPath: observedValue)
    }
    
    // MARK: - Internal methods -
    
    func loadPlayerItem()
    {
        
        if let item = playerItem
        {
            refreshPlayerItem(withAsset: item.asset)
            delegate?.wsPlayItemDidLoadPlayerItem(self)
            return
        } else if didLoad
        {
            return
        } else
        {
            didLoad = true
        }
        //(_ asset: AVURLAsset) -> ())
        loadAsync { (asset) -> () in
            if self.validateAsset(asset)
            {
                self.refreshPlayerItem(withAsset: asset)
                self.delegate?.wsPlayItemDidLoadPlayerItem(self)
            } else
            {
                self.didLoad = false
            }
        }
    }
    
    func refreshPlayerItem(withAsset asset: AVAsset)
    {
        playerItem?.removeObserver(self, forKeyPath: observedValue)
        playerItem = AVPlayerItem(asset: asset)
        playerItem?.addObserver(self, forKeyPath: observedValue, options: NSKeyValueObservingOptions.new, context: nil)
        update()
    }
    
    func update() {
        if let item = playerItem
        {
            meta.duration = item.asset.duration.seconds
            currentTime = item.currentTime().seconds
        }
    }
    
    open override var description: String
    {
        return "<WSPlayItem:\ntitle: \(meta.title)\nartist:\(meta.artist)\n,\ncurrentTime : \(currentTime)\nURL: \(URL)> in WSPlayItem.description"
    }
    
    fileprivate func validateAsset(_ asset : AVURLAsset) -> Bool
    {
        var e: NSError?
        asset.statusOfValue(forKey: "duration", error: &e)
        if let error = e
        {
            var message = "\n\n***** fatal error*****\n\n"
            if error.code == -1022
            {
                message += "It looks like you're using Xcode 7 and due to an App Transport Security issue (absence of SSL-based HTTP) the asset cannot be loaded from the specified URL: \"\(URL)\".\nTo fix this issue, append the following to your .plist file:\n\n<key>NSAppTransportSecurity</key>\n<dict>\n\t<key>NSAllowsArbitraryLoads</key>\n\t<true/>\n</dict>\n\n"
                fatalError(message)
            }
            return false
        }
        return true
    }
    
    fileprivate func scheduleNotification() {
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(WSPlayItem.notifyDelegate), userInfo: nil, repeats: false)
    }
    
    func notifyDelegate() {
        timer?.invalidate()
        timer = nil
        self.delegate?.wsPlayItemDidUpdate(self)
    }
    
    fileprivate func loadAsync(_ completion: @escaping (_ asset: AVURLAsset) -> ()) {
        let asset = AVURLAsset(url: URL, options: nil)
        
        asset.loadValuesAsynchronously(forKeys: ["duration"], completionHandler: { () -> Void in
            DispatchQueue.main.async {
                completion(asset)
            }
        })
    }
    
    fileprivate func configureMetadata()
    {
        
        DispatchQueue.global(qos: .background).async {
                let metadataArray = AVPlayerItem(url: self.URL).asset.commonMetadata
                
                for item in metadataArray
                {
                    item.loadValuesAsynchronously(forKeys: [AVMetadataKeySpaceCommon], completionHandler: { () -> Void in
                        switch item.commonKey
                        {
                        case "albumName"? :
                            self.meta.albumTitle = item.value as? String
                        default :
                            break
                        }
                        DispatchQueue.main.async {
                            self.scheduleNotification()
                        }
                    })
                }
        }
    }
}

private extension CMTime
{
    var seconds: Double?
    {
        let time = CMTimeGetSeconds(self)
        guard time.isNaN == false else { return nil }
        return time
    }
}
