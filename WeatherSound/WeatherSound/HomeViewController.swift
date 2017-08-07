//
//  HomeViewController.swift
//  WeatherSound
//
//  Created by 정교윤 on 2017. 8. 4..
//  Copyright © 2017년 정교윤. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var displayedUserName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let currentUser = Auth.auth().currentUser {
            print("displayName",currentUser.displayName)
            
            self.displayedUserName.text = currentUser.displayName ?? currentUser.email
            
            
        } else {
            print("로그인 페이지 보여줘야 함 ")
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Login") {
                
                print("login page")
                
                self.present(viewController, animated: true, completion: nil)
            }
            
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func touchUpInsideLogoutButton(_ sender: UIButton) {
        
        logoutFromFirebase()
    }
    
    
    func logoutFromFirebase() {
        
        // logout
        do {
            try Auth.auth().signOut()
            //FBSDKLoginManager().logOut()
            
            // 데이터 초기화
            
            
            // 로그인 페이지로 이동
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(vc!, animated: true, completion: nil)
            
        }catch {
            
        }

        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
