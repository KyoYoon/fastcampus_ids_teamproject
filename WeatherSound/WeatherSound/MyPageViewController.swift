//
//  MyPageViewController.swift
//  WeatherSound
//
//  Created by HyunJomi on 2017. 8. 7..
//  Copyright © 2017년 HyunJung. All rights reserved.
//

import UIKit

class MyPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var myPageTableView: UITableView!
    @IBOutlet weak var userInfoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.myPageTableView.delegate = self
        self.myPageTableView.dataSource = self
        
        //main의 locationManager호출해서 delegate 끊기
//        let main: MainViewController = (self.navigationController as? MainViewController)!
//        main.locationManager.stopMonitoringSignificantLocationChanges()
        
        self.prepareView()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareView(){
        
        let rect = self.view.bounds
        
        self.myPageTableView.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        
        return cell
    }
}
