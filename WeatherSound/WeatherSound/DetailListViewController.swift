//
//  DetailListViewController.swift
//  WeatherSound
//
//  Created by HyunJomi on 2017. 8. 19..
//  Copyright © 2017년 정교윤. All rights reserved.
//

import UIKit

class DetailListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titleBackgroundView: UIView!
    @IBOutlet weak var playListNameLabel: UILabel!
    @IBOutlet weak var tableview: UITableView!

    var detailMyPlayList: UserPlayList? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableview.register(UINib.init(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: MainTableViewCell.reuseId)
        
        self.tableview.delegate = self
        self.tableview.dataSource = self
        
        self.prepareView()
        
        self.playListNameLabel.text = self.detailMyPlayList?.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func prepareView(){
        
        let leftBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        let attributedLeftString: NSMutableAttributedString = NSMutableAttributedString(string: "< MY", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold), NSForegroundColorAttributeName: UIColor(red:0.29, green:0.26, blue:0.28, alpha:1.00)])
        leftBtn.setAttributedTitle(attributedLeftString, for: .normal)
        leftBtn.addTarget(self, action: #selector(backToMY), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        
        let rect = self.view.bounds
        
        self.titleBackgroundView.frame = CGRect(x: 0, y: 0, width: rect.width, height: 164)
        self.playListNameLabel.frame = CGRect(x: 0, y: 79, width: rect.width, height: 70)
        self.playListNameLabel.textAlignment = .center        
        self.tableview.frame = CGRect(x: 0, y: self.titleBackgroundView.frame.maxY, width: rect.width, height: rect.height-234)
        
        self.tableview.separatorStyle = .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailMyPlayList?.musicList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.reuseId) as! MainTableViewCell

        if let list = detailMyPlayList?.musicList[indexPath.row]{
            let path = list.meta
            cell.set(title: path.title, artist: path.artist)
            cell.setAlbum(urlStr: path.albumImg)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func backToMY(){
        self.navigationController?.popViewController(animated: true)
    }
}
