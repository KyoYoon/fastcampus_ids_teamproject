//
//  EditMyListViewController.swift
//  WeatherSound
//
//  Created by HyunJomi on 2017. 8. 15..
//  Copyright © 2017년 정교윤. All rights reserved.
//

import UIKit

class EditMyListViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var addNewListBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let indicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let indicatorContainer: UIView = UIView()
    
    var isEdit:Bool = false
    var selectedPk:[Int] = []
    
    let leftBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    let rightBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib.init(nibName: "EditMyListTableViewCell", bundle: nil), forCellReuseIdentifier: EditMyListTableViewCell.reuseId)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.prepareView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("EditMyList will appear")
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareView(){
        
        let rect = UIScreen.main.bounds
        
        self.addNewListBtn.frame = CGRect(x: 20, y: 85, width: rect.width-40, height: 50)
        self.tableView.frame = CGRect(x: 0, y: self.addNewListBtn.frame.maxY+10, width: rect.width, height: rect.height-140)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold), NSForegroundColorAttributeName: UIColor(red:0.29, green:0.26, blue:0.28, alpha:1.00)]
        
        let attributedLeftString: NSMutableAttributedString = NSMutableAttributedString(string: "< MY", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold), NSForegroundColorAttributeName: UIColor(red:0.29, green:0.26, blue:0.28, alpha:1.00)])
        leftBtn.setAttributedTitle(attributedLeftString, for: .normal)
        leftBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        
        self.changeAttr()
        
        rightBtn.addTarget(self, action: #selector(changeAttr), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
    }
    
    func changeAttr(){
        
        var rightString: String = ""
        var buttonString: String = ""
        
        if !self.isEdit{
            //add
            self.isEdit = true
            
            self.title = "내 리스트"
            rightString = "편집"
            buttonString = "+ 새 리스트 만들기"
            self.addNewListBtn.backgroundColor = UIColor(red:0.24, green:0.54, blue:0.90, alpha:1.00)
            
            self.leftBtn.isHidden = false
            self.tableView.allowsMultipleSelection = false
        }
        else{
            //edit
            self.isEdit = false
            self.checkErasable()
            
            self.title = "내 리스트 편집"
            rightString = "취소"
            buttonString = "리스트 삭제"
            self.addNewListBtn.backgroundColor = UIColor(red:0.47, green:0.47, blue:0.47, alpha:1.00)
            
            self.leftBtn.isHidden = true
            self.tableView.allowsMultipleSelection = true
            
        }
        
        let attributedBtnString: NSMutableAttributedString = NSMutableAttributedString(string: buttonString, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold), NSForegroundColorAttributeName: UIColor(white: 1, alpha: 1)])
        self.addNewListBtn.setAttributedTitle(attributedBtnString, for: .normal)
        
        let attributedRightString: NSMutableAttributedString = NSMutableAttributedString(string: rightString, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold), NSForegroundColorAttributeName: UIColor(red:0.29, green:0.26, blue:0.28, alpha:1.00)])
        rightBtn.setAttributedTitle(attributedRightString, for: .normal)
        
        self.selectedPk = []
        self.tableView.reloadData()
    }
    
    func back(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func checkErasable(){
        
        if self.selectedPk.count == 0{
            self.addNewListBtn.isEnabled = false
        }else{
            self.addNewListBtn.isEnabled = true
        }
    }
    
    @IBAction func addNewListBtnTouched(_ sender: UIButton) {
        if isEdit{
            //add list
//            let addListVC: AddListViewController = AddListViewController(nibName: "AddListViewController", bundle: nil)
            let addListVC: AddListViewController = AddListViewController(completion: { 
                self.tableView.reloadData()
            })
            addListVC.modalPresentationStyle = .overCurrentContext
            present(addListVC, animated: false, completion: nil)
        }else{
            //remove list
            self.showIndicator()
            
            DataCenter.shared.deleteRequestMyList(of: self.selectedPk, completion: {
                
                self.indicatorContainer.removeFromSuperview()
                
                self.changeAttr()
            })
        }
    }
    
    func showIndicator(){
        
        let rect = self.view.bounds
        
        indicatorContainer.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
        indicatorContainer.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        indicator.frame = CGRect(x:rect.midX-40, y: rect.midY-40, width: 80, height: 80)
        indicator.activityIndicatorViewStyle = .white
        
        indicatorContainer.addSubview(indicator)
        self.view.addSubview(indicatorContainer)
        
        indicator.startAnimating()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataCenter.shared.myPlayLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EditMyListTableViewCell = tableView.dequeueReusableCell(withIdentifier: EditMyListTableViewCell.reuseId, for: indexPath) as! EditMyListTableViewCell
        let playList = DataCenter.shared.myPlayLists[indexPath.row]
        
        cell.set(listName: playList.name,count: playList.musicList.count)
        cell.set(iconOf: playList.weather)
        
        if isEdit{
            cell.checkboxBtn.isHidden = true
        }else{
            cell.checkboxBtn.isHidden = false
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isEdit{
            //add
            //let detailVC: DetailListViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailListViewController") as! DetailListViewController
            //detailVC.detailMyPlayList = DataCenter.shared.myPlayLists[indexPath.row]
            //self.navigationController?.pushViewController(detailVC, animated: true)
//            let detailVC: DetailListViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailListViewController") as! DetailListViewController
//            detailVC.detailMyPlayList = DataCenter.shared.myPlayLists[indexPath.row]
//            self.navigationController?.pushViewController(detailVC, animated: true)
        }else{
            //remove
            selectedPk.append(DataCenter.shared.myPlayLists[indexPath.row].pk)
            self.checkErasable()
            print("selected: ", self.selectedPk)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        self.selectedPk = selectedPk.filter { $0 != DataCenter.shared.myPlayLists[indexPath.row].pk }
        self.checkErasable()
        print("selected: ", self.selectedPk)

        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
