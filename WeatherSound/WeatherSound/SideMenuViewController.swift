//
//  SideMenuViewController.swift
//  WeatherSound
//
//  Created by HyunJomi on 2017. 8. 11..
//  Copyright © 2017년 정교윤. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var homeBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var editProfile: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
 
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(tapGestureHandler))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
//        let rect = self.view.frame
        let rect = UIScreen.main.bounds
        self.menuContainerView.frame = CGRect(x: rect.width*0.4, y: 0, width: rect.width*0.6, height: rect.height)
        
        self.homeBtn.frame = CGRect(x: 20, y: 100, width: self.menuContainerView.frame.width, height: 50)
        self.editProfile.frame = CGRect(x: 20, y: self.homeBtn.frame.maxY+10, width: self.menuContainerView.frame.width, height: 50)
        self.logoutBtn.frame = CGRect(x: 20, y: self.editProfile.frame.maxY+10, width: self.menuContainerView.frame.width, height: 50)
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    @IBAction func homeBtnTouched(_ sender: UIButton) {
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func logOutBtonTouched(_ sender: UIButton) {
    }
    
    @IBAction func editProfileBtnTouched(_ sender: UIButton) {
    }
    
    let myTansitioning: SideMenuTransition = SideMenuTransition()
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.myTansitioning.isPresent = true
        return self.myTansitioning
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.myTansitioning.isPresent = false
        return self.myTansitioning
    }
    
    func tapGestureHandler(){
        self.dismiss(animated: true, completion: nil)
    }
    
}

