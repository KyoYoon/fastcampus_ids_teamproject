//
//  AddListViewController.swift
//  WeatherSound
//
//  Created by HyunJomi on 2017. 8. 16..
//  Copyright © 2017년 정교윤. All rights reserved.
//

import UIKit

class AddListViewController: UIViewController {

    @IBOutlet weak var popView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var insertTitleTF: UITextField!
    
    let indicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let indicatorContainer: UIView = UIView()

    private var addCallback: (()->Void)?
    
    init(completion: (()->Void)?) {
        super.init(nibName: "AddListViewController", bundle: nil)
        self.addCallback = completion
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        let rect = UIScreen.main.bounds
        self.popView.frame = CGRect(x: 20, y: 150, width: rect.width-40, height: 160 )
        
        self.cancelBtn.frame = CGRect(x: 10, y: 20, width: 40, height: 40)
        self.titleLabel.frame = CGRect(x: self.popView.frame.midX-70, y: 20, width: 120, height: 40)
        self.submitBtn.frame = CGRect(x: self.popView.frame.maxX-80, y: 20, width: 50, height: 40)
        self.insertTitleTF.frame = CGRect(x: 20, y: self.titleLabel.frame.maxY+20, width: rect.width-80, height: 50)
    
        self.insertTitleTF.layer.borderWidth = 1
        self.insertTitleTF.layer.cornerRadius = 5
        self.insertTitleTF.layer.borderColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.00).cgColor
    
        self.insertTitleTF.becomeFirstResponder()
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(tapGestureHandler))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tapGestureHandler(){
        self.insertTitleTF.resignFirstResponder()
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func cancelBtn(_ sender: UIButton) {
        self.insertTitleTF.resignFirstResponder()
        self.dismiss(animated: false, completion: nil)
    }
    

    
    @IBAction func submitBtnTouched(_ sender: UIButton) {
        
        self.showIndicator()
        
        
        guard let newListName = self.insertTitleTF.text else {
            return
        }
        
        DataCenter.shared.addMyListRequest(list: newListName, music: nil) {
            self.addCallback?()
            self.dismiss(animated: false, completion: nil)
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
}
