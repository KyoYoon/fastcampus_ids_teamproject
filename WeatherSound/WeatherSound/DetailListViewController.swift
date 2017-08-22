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
    
    let leftBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    let rightBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    let deleteBtn : UIButton = UIButton(frame: CGRect(x: 20, y: 0, width: UIScreen.main.bounds.width-40, height: 40))
    
    var detailIndex: Int?{
        didSet{
            self.detailList = DataCenter.shared.myPlayLists[self.detailIndex!]
        }
    }
    var detailList: UserPlayList? = nil
    
    var isEditMode: Bool = false
    var selectedPk: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableview.register(UINib.init(nibName: "EditMyListTableViewCell", bundle: nil), forCellReuseIdentifier: EditMyListTableViewCell.reuseId)
        
        self.tableview.delegate = self
        self.tableview.dataSource = self
        
        self.prepareView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func prepareView(){
        
        self.playListNameLabel.text = self.detailList?.name
        
        let attributedLeftString: NSMutableAttributedString = NSMutableAttributedString(string: "< 뒤로", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold), NSForegroundColorAttributeName: UIColor(red:0.29, green:0.26, blue:0.28, alpha:1.00)])
        leftBtn.setAttributedTitle(attributedLeftString, for: .normal)
        leftBtn.addTarget(self, action: #selector(popToBack), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        
        rightBtn.addTarget(self, action: #selector(changetoEdit), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        
        self.changetoEdit()
        
        let rect = self.view.bounds
        
        self.titleBackgroundView.frame = CGRect(x: 0, y: 0, width: rect.width, height: 164)
        self.playListNameLabel.frame = CGRect(x: 0, y: 79, width: rect.width, height: 70)
        self.playListNameLabel.textAlignment = .center
        self.tableview.frame = CGRect(x: 0, y: self.titleBackgroundView.frame.maxY, width: rect.width, height: rect.height-234)
        
        self.tableview.separatorStyle = .none
    }
    
    func changetoEdit(){
        
        var rightNaviStr:String = ""
        
        if self.isEditMode{
            rightNaviStr = "취소"
            self.tableview.allowsMultipleSelection = true
            
            self.isEditMode = false
        }else{
            rightNaviStr = "편집"
            self.tableview.allowsMultipleSelection = false
            
            self.isEditMode = true
        }
        let attributedRightString: NSMutableAttributedString = NSMutableAttributedString(string: rightNaviStr, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold), NSForegroundColorAttributeName: UIColor(red:0.29, green:0.26, blue:0.28, alpha:1.00)])
        rightBtn.setAttributedTitle(attributedRightString, for: .normal)
        
        self.tableview.reloadData()
    }
    
    func popToBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func checkErasable(){
        
        if self.selectedPk.count == 0{
            self.deleteBtn.isEnabled = false
        }else{
            self.deleteBtn.isEnabled = true
        }
    }
    
    func deleteBtnTouched(){
        guard let listPK = self.detailList?.pk else {
            return
        }
        DataCenter.shared.deleteRequestMyMusic(list: listPK, of: self.selectedPk) {
            self.detailList = DataCenter.shared.myPlayLists[self.detailIndex!]
            self.changetoEdit()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.detailList?.musicList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:EditMyListTableViewCell = tableView.dequeueReusableCell(withIdentifier: EditMyListTableViewCell.reuseId) as! EditMyListTableViewCell
        
        if let list = detailList?.musicList[indexPath.row]{
            //WSPlayItem
            //            let path = list.meta
            //            cell.set(title: path.title, artist: path.artist)
            //            cell.setAlbum(urlStr: path.albumImg)
            
            //Music
            cell.set(title: list.title, artist: list.artist)
            cell.setAlbum(urlStr: list.albumImg)
        }
        if isEditMode{
            cell.checkboxBtn.isHidden = true
        }else{
            cell.checkboxBtn.isHidden = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditMode{
            
        }
        else{
            self.selectedPk.append((self.detailList?.musicList[indexPath.row].pk)!)
            self.checkErasable()
             print("selected: ", self.selectedPk)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.selectedPk = selectedPk.filter { $0 != self.detailList?.musicList[indexPath.row].pk }
        self.checkErasable()
        print("selected: ", self.selectedPk)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        deleteBtn.backgroundColor = UIColor(red:0.47, green:0.47, blue:0.47, alpha:1.00)
        let attrBtnStr: NSMutableAttributedString = NSMutableAttributedString(string: "선택 삭제", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold), NSForegroundColorAttributeName: UIColor.white])
        deleteBtn.setAttributedTitle(attrBtnStr, for: .normal)
        deleteBtn.addTarget(self, action: #selector(deleteBtnTouched), for: .touchUpInside)
        view.addSubview(deleteBtn)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !isEditMode{
            return 40
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
