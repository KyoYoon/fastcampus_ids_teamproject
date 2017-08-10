//
//  MainTableViewCell.swift
//  WeatherSound
//
//  Created by HyunJomi on 2017. 8. 2..
//  Copyright © 2017년 HyunJung. All rights reserved.
//

import UIKit
import SDWebImage

class MainTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    static let reuseId = "musicCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.prepareCell()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func prepareCell(){
        
        self.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        self.backgroundView = blurEffectView

        self.titleLabel.textAlignment = .left
        self.titleLabel.frame = CGRect(x: self.albumImageView.frame.maxX+10, y: self.frame.minY+5, width: self.frame.width-80, height: 50)
        
        self.albumImageView.backgroundColor = .gray
        self.albumImageView.frame = CGRect(x: 20, y: self.frame.minY+5, width: 50, height: 50)
        

    }
    
    func set(title: String, artist: String){
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "\(title)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightThin), NSForegroundColorAttributeName: UIColor(red:0.29, green:0.26, blue:0.28, alpha:1.00)])
        attributedString.append(NSAttributedString(string: "\n\(artist)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 13, weight: UIFontWeightThin), NSForegroundColorAttributeName: UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.00)]))
        
        self.titleLabel.attributedText = attributedString
    }
    
    func setAlbum(urlStr: String){
        
        if let url = URL(string: urlStr){
  
            self.albumImageView.sd_setImage(with: url)
        }
    }
    
}
