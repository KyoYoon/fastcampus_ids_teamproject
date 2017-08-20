//
//  EditMyListTableViewCell.swift
//  WeatherSound
//
//  Created by HyunJomi on 2017. 8. 16..
//  Copyright © 2017년 정교윤. All rights reserved.
//

import UIKit

class EditMyListTableViewCell: UITableViewCell{

    static let reuseId = "EditMyListCell"
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var checkboxBtn: UIButton!
    @IBOutlet weak var infoSubLabel: UILabel!
    
    var isEdit: Bool = false
    var delegate: CellSelectedDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.cellImageView.frame = CGRect(x: 20, y: 5, width: 60, height: 60)
        self.infoLabel.frame = CGRect(x: self.cellImageView.frame.maxX+10, y: 13, width: 150, height: 25)
        self.infoSubLabel.frame = CGRect(x: self.cellImageView.frame.maxX+10, y: self.infoLabel.frame.maxY, width: 150, height: 25)
        self.checkboxBtn.frame = CGRect(x: UIScreen.main.bounds.width-50, y: self.frame.midY-10, width: 20, height: 20)
        self.checkboxBtn.layer.cornerRadius = 10
        self.checkboxBtn.layer.borderColor = UIColor(red:0.27, green:0.27, blue:0.27, alpha:1.00).cgColor
        self.checkboxBtn.layer.borderWidth = 1
        
        if isEdit{
            self.checkboxBtn.isHidden = false
        }else{
            self.checkboxBtn.isHidden = true
        }
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.selectionStyle = .none
        if selected{
            self.checkboxBtn.backgroundColor = UIColor(red:0.27, green:0.27, blue:0.27, alpha:1.00)
        }else{
            self.backgroundColor = .white
            self.checkboxBtn.backgroundColor = .white
        }
        
    
    }
    func set(listName: String, count: Int){
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "\(listName)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightThin), NSForegroundColorAttributeName: UIColor(red:0.29, green:0.26, blue:0.28, alpha:1.00)])
        
        let attributedSubString: NSMutableAttributedString = NSMutableAttributedString(string: "\(count)곡", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin), NSForegroundColorAttributeName: UIColor(red:0.29, green:0.26, blue:0.28, alpha:1.00)])
        
        self.infoLabel.attributedText = attributedString
        self.infoSubLabel.attributedText = attributedSubString
    }
    
    func set(iconOf: String){
        
        let icon: UIImage
        
        switch iconOf {
            case "sunny":
                icon = #imageLiteral(resourceName: "sunny")
            case "snowy":
                icon = #imageLiteral(resourceName: "snowy")
            case "foggy":
                icon = #imageLiteral(resourceName: "foggy")
            case "rainy":
                icon = #imageLiteral(resourceName: "rainny")
            case "cloudy":
                icon = #imageLiteral(resourceName: "cloudy")
            default:
                icon = #imageLiteral(resourceName: "question")
        }
        
        self.cellImageView.image = icon
    }
    
    @IBAction func checkBoxBtnTouched(_ sender: UIButton) {

        delegate?.selectRemove(cell: self)
    }
}

protocol CellSelectedDelegate {
    func selectRemove(cell: EditMyListTableViewCell)
}
