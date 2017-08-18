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
    
    var isEdit: Bool = false
    var delegate: CellSelectedDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.cellImageView.frame = CGRect(x: 20, y: 8, width: 64, height: 64)
        self.infoLabel.frame = CGRect(x: self.cellImageView.frame.maxX+5, y: 8, width: 150, height: 64)
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
//
//        self.selectionStyle = .none
//        if selected{
//            self.backgroundColor = .clear
//        }
        
    
    }
    @IBAction func checkBoxBtnTouched(_ sender: UIButton) {

        delegate?.selectRemove(cell: self)
    }
}

protocol CellSelectedDelegate {
    func selectRemove(cell: EditMyListTableViewCell)
}
