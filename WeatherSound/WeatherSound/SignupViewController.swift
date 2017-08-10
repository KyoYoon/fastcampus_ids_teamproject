//
//  SignupViewController.swift
//  WeatherSound
//
//  Created by 정교윤 on 2017. 8. 1..
//  Copyright © 2017년 정교윤. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Alamofire
import SwiftyJSON

class SignupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // swifty json 사용 후 데이터 선언
    var data : JSON = JSON.init(rawValue: [])!
    
    var dbRef : DatabaseReference! // 파이어베이스 데이터베이스 인스턴스 변수
    var storageRef : StorageReference! // 파이어베이스 스토리지 인스턴스 변수
    
    @IBOutlet weak var profileImageButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField! // email address
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField! // password (8자리 이상)
    
    @IBOutlet weak var passwordConfirmTextField: UITextField! // password 확인 필드 
    

    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    
    //var isProfileImageInsideButton:Bool = false
    //var isNickNameEntered:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.dbRef = Database.database().reference() // 데이터베이스 인스턴스 생성
        self.storageRef = Storage.storage().reference() // 스토리지 인스턴스 생성
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.profileImageButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.profileImageButton.layer.cornerRadius = 106.3 / 2
        self.profileImageButton.layer.borderWidth = 1
        //self.profileImageButton.layer.backgroundColor = UIColor.black.cgColor
        
        //self.emailTextField.borderStyle = .roundedRect
        //self.nicknameTextField.borderStyle = .roundedRect
        //self.passwordTextField.borderStyle = .roundedRect
        
        self.emailTextField.text = ""
        self.nicknameTextField.text = ""
        self.passwordTextField.text = ""
        self.passwordConfirmTextField.text = ""
        
        self.signupButton.layer.cornerRadius = 5
        
        
        self.signupButton.isEnabled = false

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        signupButtonActivated()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func touchUpInsideCancelButton(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        //self.emailTextField.resignFirstResponder()
        //self.nicknameTextField.resignFirstResponder()
        //self.passwordTextField.resignFirstResponder()
        //self.passwordConfirmTextField.resignFirstResponder()
        
        
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //self.scrollView.setContentOffset(CGPoint(x: 0.0, y: 200.0), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //self.scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 1...300:
            print(textField.tag)
            self.view.viewWithTag(textField.tag + 100)?.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
            self.signupRequestFirebase()
        }
        
        return true
    }


    @IBAction func touchUpInsideProfileImageButton(_ sender: UIButton) {
        
        photoActionHandler()
        
    }
    
    func photoActionHandler() {
        print ("action Photo")
        
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true // edit된 이미지 가져올 때
        self.present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        print("info://",info)
        
        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage else {
            return
        }
        
        // UIImagePickerControllerCropRect -> crop된 이미지 사이즈 가져올 때
        // UIImagePickerControllerEditedImage -> edit딘 이미지 가져올 때
        
        image.withRenderingMode(.alwaysOriginal) // 이미지 변조가 일어날 경우를 대비해 항상 오리지널 이미지로 셋팅 (틴트 컬러 등에 의해 자동으로 이미지 변환이 일어나기 때문)
        
        
        
        self.profileImageButton.setImage(image, for: .normal)
        self.profileImageButton.clipsToBounds = true
        
        // 사진이 로딩되었으므로 플래그를 바꾼다.
        //self.isProfileImageInsideButton = true
        
        self.dismiss(animated: true, completion: nil)
    }

    
    @IBAction func touchUpInsideJoinAsMemberButton(_ sender: UIButton) {
        
        signupRequestFirebase()
    }
    
    func signupRequestFirebase() {
        
        
        self.view.endEditing(true)
        
        let providedEmailAddress = self.emailTextField.text
        
        
        
        let isEmailAddressValid = CommonLibraries.sharedFunc.isValidEmailAddress(emailAddressString: providedEmailAddress!)
        
        if isEmailAddressValid == false {
            
            CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Error", messageToDisplay: "이메일 주소가 유효하지 않습니다. 다시 입력하여 주세요.")
            
            
        } else {
            
            
            // 비밀번호 유효성 검사
            if CommonLibraries.sharedFunc.isPasswordValid(password: self.passwordTextField.text!) == false { // 패스워드가 유효하지 않을 때
                
                CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Error", messageToDisplay: "패스워드는 최소 8자리이상 입력하셔야 하며 대문자 소문자 숫자 및 특수문자가 반드시 포함되어야 합니다.")
                
            }
            else if self.passwordTextField.text != self.passwordConfirmTextField.text {
                
                CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Error", messageToDisplay: "입력하신 패스워드 2개가 서로 일치하지 않습니다. 같은 패스워드를 넣어주세요.")
                
            }
            else { // 비밀번호가 유효하면 사용자 계정 생성 및 프로필 이미지 저장
                
                Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                    
                    if error == nil {
                        print("You have successfully signed up")
                        //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
                        
                        let email = self.emailTextField.text
                        let password = self.passwordTextField.text
                        let nickName = self.nicknameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "없음"
                        
                        //let trim = self.nicknameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        // success
                        let uid = user?.uid // random string => 로그온한 사용자를 구별할 수 있는 유일한 키
                        let image = self.profileImageButton.imageView?.image ?? UIImage(named: "mypage_no_profile")! // 사용자가 업로드한 이미지가 없다면 디폴트 이미지를 가져온다.
                        
                        let uploadData = UIImageJPEGRepresentation(image, 0.3) // 30% 수준으로 이미지 압축을 한다.
                        
                        
                        let uuid = UUID().uuidString // random string
                        
                        // 파이어베이스 스토리지에 먼저 그림을 저장을 한 후 저장 과정이 끝나면 파이어베이스 데이터베이스에 관련 정보와 nickname을 업데이트한다.
                        self.storageRef.child("ProfileImage").child(uuid).putData(uploadData!, metadata: nil, completion: { (metaData, error) in
                            
                            if let error = error {
                                print("error://",error)
                                return
                            }
                            
                            // 수정
                            print("metaData://",metaData ?? "no metaData")
                            
                            guard let urlStr = metaData?.downloadURL()?.absoluteString else { return } // 업로드한 이미지의 다운로드 주소 추출
                            print(urlStr)
                            
                            // userName 과 profileImg 속성을 추가하여 업데이트한다. profileImg 속성에는 업로드 이미지의 다운로드 주소가 들어감
                            self.dbRef.child("MyUser").child(uid!).child("UserInfo").updateChildValues(["email":email!,"password":password!,"nickname":nickName,"img_profile":urlStr], withCompletionBlock: { (error, ref) in
                                
                                if let error = error {
                                    print("error://",error)
                                    return
                                }
                                
                                // 로그온처리 후 main page 이동
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                                self.present(vc!, animated: true, completion: nil)
                                
                            })
                            
                            
                            
                        })
                        
                        
                    } else {
                        
                        CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Error", messageToDisplay: (error?.localizedDescription)!)
                        
                        
                    }
                }
                
            }
            
        }
        
        
    }
    
    // 직접 서버에 요청해서 회원가입과 동시에 처리한다.
    func signupRequestAlamoFire(with email:String, nickname:String, password:String, passwordConfirm:String) {
        
        // 1. 회원가입 처리
        
        // https://weather-sound.com/api/member/signup/
        //보낼 때 데이터 구조 - POST
//        {
//            "email_account": "kyoyoon@bbbb.com",
//            "nickname": "정교윤",
//            "password1": "123456",
//            "password2": "123456"
//        }
        
        // 결과값 response
//        {
//            "email_account": "kyoyoon@bbbb.com",
//            "nickname": "정교윤"
//        }
        
        // 2. 로그인 처리
        // https://weather-sound.com/api/member/login/ 
        
        
        // 보낼 때 데이터구조 - POST
//        {
//            "email_account": "kyoyoon@bbbb.com",
//            "password": "123456"
//        }
        
        // 결과값 response - 이 데이터 중 이메일을 세션 유지용 데이터로 활용 
//        "email": "kyoyoon@bbbb.com",
//        "username": "정교윤",
//        "img_profile": "https://s3.ap-northeast-2.amazonaws.com/weather-sound-test-s3-bucket/media/member/basic_profile.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIUNOVI4KACUE6OMQ%2F20170808%2Fap-northeast-2%2Fs3%2Faws4_request&X-Amz-Date=20170808T113635Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=76044d42a01be1256511ad64a8b961dff4b2397d13820c7229750ff0dabe3bfc"
        
        
        // 3. 로그온 처리와 동시에 UserDefaults에 email을 저장해놓고 로그온 되어있는지 처리용으로 확인함
        // 위의 정보를 DataCenter에 저장하고 email은 UserDefaults에 저장한다. 
        
    }
    
    func resetPasswordFirebase() {
        
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
    
    @IBAction func touchUpInsideResetPasswordButton(_ sender: UIButton) {
        
        resetPasswordFirebase()
        
    }
    
    
    func signupButtonActivated() {
        
        let isFormVaild = self.emailTextField.text?.characters.count ?? 0 > 0 && self.passwordTextField.text?.characters.count ?? 0 > 0 && self.passwordConfirmTextField.text?.characters.count ?? 0 > 0
        
        
        
        if isFormVaild {
            self.signupButton.isEnabled = true
            self.signupButton.backgroundColor = UIColor.rgbColor(74, 144, 226)
            
        } else {
            self.signupButton.isEnabled = false
            self.signupButton.backgroundColor = UIColor.rgbColor(149, 204, 244)
        }
        
    }
    
    @IBAction func emailTextFieldEditingChanged(_ sender: UITextField) {
        
        signupButtonActivated()
        
    }
    
    @IBAction func passworldTextFieldEditingChanged(_ sender: UITextField) {
        
        signupButtonActivated()
        
    }
    
    @IBAction func passwordConfirmTextFieldEditingChanged(_ sender: UITextField) {
        
        signupButtonActivated()
        
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
