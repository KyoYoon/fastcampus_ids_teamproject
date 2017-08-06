//
//  ViewController.swift
//  WeatherSound
//
//  Created by 정교윤 on 2017. 7. 28..
//  Copyright © 2017년 정교윤. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit

class LoginViewController: UIViewController {

    var dbRef : DatabaseReference! // 파이어베이스 데이터베이스 인스턴스 변수
    var storageRef : StorageReference! // 파이어베이스 스토리지 인스턴스 변수
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.dbRef = Database.database().reference() // 데이터베이스 인스턴스 생성
        self.storageRef = Storage.storage().reference() // 스토리지 인스턴스 생성
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
        
        self.loginButton.layer.cornerRadius = 5
        self.loginButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    @IBAction func emailTextFieldEditingChanged(_ sender: UITextField) {
        
        loginButtonActivated()
        
    }
    
    @IBAction func passwordTextFieldEditingChanged(_ sender: UITextField) {
        
        loginButtonActivated()
        
    }
    
    // 이메일/비밀번호로 로그인
    @IBAction func touchUpInsideLoginButton(_ sender: UIButton) {
        
        let providedEmailAddress = self.emailTextField.text
        
        let isEmailAddressValid = CommonLibraries.sharedFunc.isValidEmailAddress(emailAddressString: providedEmailAddress!)
        
        if isEmailAddressValid == false {
            
            CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Error", messageToDisplay: "이메일 주소가 유효하지 않습니다. 다시 입력하여 주세요.")
            
            
        } else {
            
            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                
                
                if error == nil {
                    
                    // success
                    print("userID", user?.uid)
                    
                    let email = self.emailTextField.text
                    let password = self.passwordTextField.text
                    
                    let uid = user?.uid
                    
                    // 이메일, 패스워드 항상 업데이트
                
                    self.dbRef.child("MyUser").child(uid!).child("UserInfo").updateChildValues(["email":email!,"password":password!], withCompletionBlock: { (error, ref) in
                        
                        if let error = error {
                            print("error://",error)
                            return
                        }
                        
                        // 로그온처리 후 main page 이동
                        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Home") {
                            UIApplication.shared.keyWindow?.rootViewController = viewController
                            self.dismiss(animated: true, completion: nil)
                        }
                        
                    })

                    
                    // 로그온 처리 후 Home View Controller로 이동
                    //let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                    //self.present(vc!, animated: true, completion: nil)
                    
                } else {
                    
                    CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Error", messageToDisplay: (error?.localizedDescription)!)
                    
                }
                
            }

            
        }
        
        
        
    }
    
    // 페이스북 로그인 - 가입과 동시에 로그온 처리 => 그 뒤부터는 계속 로그온 상태임..
    @IBAction func touchUpInsideFacebookLoginButton(_ sender: UIButton) {
        
        let fbLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                
                if error == nil {
                    
                    print("You have successfully signed up")
                    //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
                    
                    
                    // 페이스북 로그온의 경우 패스워드 정보는 저장할 필요가 없음 - 2017.08.07
                    let email = user?.email
                    let password = ""
                    let nickName = user?.displayName ?? "없음"
                    
                    //let trim = self.nicknameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // success
                    let uid = user?.uid // random string => 로그온한 사용자를 구별할 수 있는 유일한 키
                    let image = UIImage(named: "mypage_no_profile")! // 디폴트 이미지를 가져온다.
                    
                    let uploadData = UIImageJPEGRepresentation(image, 0.3) // 30% 수준으로 이미지 압축을 한다.
                    
                    let uuid = UUID().uuidString // random string
 
                    // 파이어베이스 스토리지에 먼저 그림을 저장을 한 후 저장 과정이 끝나면 파이어베이스 데이터베이스에 관련 정보와 nickname을 업데이트한다.
                    self.storageRef.child("ProfileImage").child(uuid).putData(uploadData!, metadata: nil, completion: { (metaData, error) in
                        
                        if let error = error {
                            print("error://",error)
                            return
                        }
                        
                        print("metaData://",metaData ?? "no metaData")
                        
                        guard let urlStr = metaData?.downloadURL()?.absoluteString else { return } // 업로드한 이미지의 다운로드 주소 추출
                        print(urlStr)
                        
                        // userName 과 profileImg 속성을 추가하여 업데이트한다. profileImg 속성에는 업로드 이미지의 다운로드 주소가 들어감
                        self.dbRef.child("MyUser").child(uid!).child("UserInfo").updateChildValues(["email":email!,"password":password,"nickname":nickName,"img_profile":urlStr], withCompletionBlock: { (error, ref) in
                            
                            if let error = error {
                                print("error://",error)
                                return
                            }
                            
                            // 로그온처리 후 main page 이동
                            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Home") {
                                UIApplication.shared.keyWindow?.rootViewController = viewController
                                self.dismiss(animated: true, completion: nil)
                            }
                            
                        })
                        
                        
                        
                    })

                    
                    
                } else {
                    
                    print("Login error: \(String(describing: error?.localizedDescription))")
                    CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Facebook Login Error", messageToDisplay: (error?.localizedDescription)!)
                    
                }
                
                
            })
        }
        
    }
    
    @IBAction func touchUpInsideResetPasswordButton(_ sender: UIButton) {
        
        // 이메일 주소를 입력하였는지 확인 후 입력되었으면 파이어베이스 서버에 이메일 재설정 요청하면 파이어베이스에서 재설정 하라는 링크를 이메일로 보내주며 사용자가 그 링크를 통해 이메일을 재설정하면 됨
        
        if self.emailTextField.text == "" {
            
            CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Oops!", messageToDisplay: "이메일 주소를 입력하여 주세요!")
            
            
            
        } else {
            
            Auth.auth().sendPasswordReset(withEmail: self.emailTextField.text!, completion: { (error) in
                
                var title = ""
                var message = ""
                
                if error != nil {
                    title = "Error!"
                    message = (error?.localizedDescription)!
                } else {
                    title = "Success!"
                    message = "패스워드 재설정 메일이 귀하의 이메일 주소로 전송되었습니다."
                    self.emailTextField.text = ""
                }
                
                CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: title, messageToDisplay: message)
                
                
            })
        }
        
    }
    
    
    func loginButtonActivated() {
        
        let isFormVaild = self.emailTextField.text?.characters.count ?? 0 > 0 && self.passwordTextField.text?.characters.count ?? 0 > 0
        
        if isFormVaild {
            self.loginButton.isEnabled = true
            self.loginButton.backgroundColor = UIColor.rgbColor(74, 144, 226)
            
        } else {
            self.loginButton.isEnabled = false
            self.loginButton.backgroundColor = UIColor.rgbColor(149, 204, 244)
        }
        
    }
    
    


}

