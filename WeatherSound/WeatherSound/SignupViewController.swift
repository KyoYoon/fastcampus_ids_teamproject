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
    //var data : JSON = JSON.init(rawValue: [])!
    
    var dbRef : DatabaseReference! // 파이어베이스 데이터베이스 인스턴스 변수
    var storageRef : StorageReference! // 파이어베이스 스토리지 인스턴스 변수
    
    @IBOutlet weak var profileImageButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField! // email address
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField! // password (8자리 이상)
    
    @IBOutlet weak var passwordConfirmTextField: UITextField! // password 확인 필드 
    

    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
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
        self.resetPasswordButton.isHidden = true
        
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
            //self.signupRequestFirebase()
            self.signupRequestAlamoFire()
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
        
        /// chcek if you can return edited image that user choose it if user already edit it(crop it), return it as image
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            
            /// if user update it and already got it , just return it to 'self.imgView.image'
            
            self.profileImageButton.setImage(editedImage, for: .normal)
            self.profileImageButton.clipsToBounds = true
            
            
            
            /// else if you could't find the edited image that means user select original image same is it without editing .
        } else if let orginalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            
            /// if user update it and already got it , just return it to 'self.imgView.image'.
            self.profileImageButton.setImage(orginalImage, for: .normal)
            self.profileImageButton.clipsToBounds = true
            
            
        }
        else { print ("error") }
        
        /// if the request successfully done just dismiss
        self.dismiss(animated: true, completion: nil)
        
        
        
        
    }

    
    @IBAction func touchUpInsideJoinAsMemberButton(_ sender: UIButton) {
        
        //signupRequestFirebase()
        
        signupRequestAlamoFire()
        
    }
    
    func signupRequestFirebase() {
        
        
        self.view.endEditing(true)
        
        let providedEmailAddress = self.emailTextField.text
        
        if providedEmailAddress == "" {
            
            CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Error", messageToDisplay: "이메일 주소를 입력하지 않았습니다. 이메일 주소를 입력하여 주세요.")
            
            return
            
        }
        
        
        let isEmailAddressValid = CommonLibraries.sharedFunc.isValidEmailAddress(emailAddressString: providedEmailAddress!)
        
        if isEmailAddressValid == false {
            
            CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Error", messageToDisplay: "이메일 주소가 유효하지 않습니다. 다시 입력하여 주세요.")
            
            
        } else {
            
            
            if CommonLibraries.sharedFunc.isPasswordValid(password: self.passwordTextField.text!) == false { // 비밀번호가 유효하지 않을 때
                
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
    
    
    // Multipart 기반 Signup 함수 
    func signupRequestAlamoFire() {
        
        
        let parameters: Parameters = ["username": self.emailTextField.text!,
                                      "nickname": self.nicknameTextField.text!,
                                      "password1": self.passwordTextField.text!,
                                      "password2": self.passwordConfirmTextField.text!]
        
        
        
        let signupUrl:String = Authentication.signupURL
        let loginUrl:String = Authentication.loginURL
        
        print("-------------------- signupRequestAlamofire -------------------")
        
        Alamofire.upload(
            
            multipartFormData: { multipartFormData in
                
                // 그림파일 append
                if let image = self.profileImageButton.image(for: .normal) {
                    
                    print("image uploaded")
                    
                    let imageData = UIImageJPEGRepresentation(image, 0.7)
                    multipartFormData.append(imageData!, withName: "img_profile", fileName: "photo.jpg", mimeType: "jpg/png")
                }
                
                // 스트링 값으로 구성된 파라메터 append
                for (key, value) in parameters {
                    if value is String || value is Int {
                        multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                    }
                }
                
                
        },
            to: signupUrl,
            method: .post,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        
                        //response.response?.statusCode
                        
                        print("Status Code: ",response.response?.statusCode ?? "no status code")
                        
                        // 로그인 리퀘스트 함수를 호출
                        let statusCode = (response.response?.statusCode)!
                        if statusCode == 201 { // 성공 (Created)
                            
                            // 로그온 처리
//                            self.loginRequestAlamofire(loginUrl: loginUrl)
                            self.dismiss(animated: true, completion: nil)
                        } else { // error 발생으로 간주
                            
                            if ((response.result.value) != nil) {
                                
                                
                                let json = JSON(response.result.value!)
                                
                                
                                if json["detail"].arrayObject != nil {
                         
                                    // 서버에서 받아서 메시지 뿌려줌
                                    CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Error", messageToDisplay: json["detail"][0].stringValue)
                                    
                                } else if json["username"].arrayObject != nil {
                                    
                                    // 서버에서 받아서 메시지 뿌려줌
                                    CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Error", messageToDisplay: json["username"][0].stringValue)
                                    
                                } else {
                                    
                                    CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Error", messageToDisplay: "Unknown Error")
                                    
                                }
                                
                            } else {
                                
                                CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Error", messageToDisplay: "Unknown Error")
                                
                            }
                            
                            
                            
                        }
                        
                        
                    }
                case .failure(let encodingError):
                    print(encodingError)
                    
                    CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Error", messageToDisplay: encodingError.localizedDescription)
                    
                }
        })
        
        
        
    }
    
    // 로그인 성공시 받아오는 JSON 구조
//    {
//    "token": "71c81443a6f8a065f424c7ac7d13ceb20d4cd47f",
//    "userInfo": {
//    "pk": 47,
//    "email": "eraka34455@cccc.com",
//    "username": "eraka",
//    "img_profile": "https://s3.ap-northeast-2.amazonaws.com/weather-sound-test-s3-bucket/media/member/basic_profile.png",
//    "password": "pbkdf2_sha256$36000$UaFTWXiLQVGZ$epc0MEr5A8kKwacz6KpLj8w+2M5uYv/AcXRtIM/VUW0=",
//    "is_active": true,
//    "is_admin": false
//    }
//    }
    
    // 로그인 처리
    func loginRequestAlamofire(loginUrl:String) {
        
        print("-------------------- loginRequestAlamofire -------------------")
        print("login processing")
        
        // 로그온 처리 후 main page 이동
        let loginParameters: Parameters = [
            "username": self.emailTextField.text!,
            "password": self.passwordTextField.text!
        ]
        
        // 로그인 처리
        Alamofire.request(loginUrl, method: .post, parameters: loginParameters, encoding: JSONEncoding.prettyPrinted).responseJSON { (response) in
            
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                print("JSON: \(json)")
                
                // statusCode가 202이 아니라면 에러 메시지를 뿌리고 롤백한다.
                let statusCode = (response.response?.statusCode)!
                print("...HTTP code: \(statusCode)")
                
                if statusCode == 202 { // Accepted
                
                    // 데이터 센터에 값 삽입
                    LoginDataCenter.shared.parseMyLoginInfo(with: json)
                    
                    print(LoginDataCenter.shared.myLoginInfo!)
                    
                    // pk 저장 (UserDefaults)
                    UserDefaults.standard.setValue(LoginDataCenter.shared.myLoginInfo?.pk, forKey: Authentication.pk)
                    
                    // token 저장 (UserDefaults)
                    UserDefaults.standard.setValue(LoginDataCenter.shared.myLoginInfo?.token, forKey: Authentication.token)
                    
                    // myLoginInfo 전체 데이터 UserDefaults에 저장
                    LoginDataCenter.shared.saveMyLoginInfoInUserDefault(myLoginInfo: LoginDataCenter.shared.myLoginInfo!)
                    
                    // 로그온 상태 저장
                    UserDefaults.standard.setValue(true, forKey: Authentication.isLoginSucceed)
                    
                    UserDefaults.standard.setValue(false, forKey: Authentication.isFacebookLogin)
                    
                    // 프로필 편집 뷰 컨트롤러로 이동 
                    //self.moveToProfileEdit()
                    
                    // My Page View Controller 로 이동
                    //self.moveToMyPageView()
                    
                    // MainView Controller로 이동
                    //self.moveToMainView()
                    
                    // Container View Controller로 이동
                    self.moveToContainerView()
                    
                    // 뒤의 View Controller 로 롤백
                    //self.dismiss(animated: false, completion: nil)
                
                } else {
                    
                    UserDefaults.standard.setValue(false, forKey: Authentication.isLoginSucceed)
                    
                    UserDefaults.standard.setValue(false, forKey: Authentication.isFacebookLogin)
                    
                    CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Error", messageToDisplay: json["detail"][0].stringValue)
                    
                }
                
                break
            case .failure(let error):
                
                print(error)
                
                UserDefaults.standard.setValue(false, forKey: Authentication.isLoginSucceed)
                
                UserDefaults.standard.setValue(false, forKey: Authentication.isFacebookLogin)
                
                CommonLibraries.sharedFunc.displayAlertMessageAndDissmiss(vc: self, title: "Error", messageToDisplay: error.localizedDescription)
                
                break
            }
            
            
        }
        
    }
    
    // Container View Controller로 이동
    func moveToContainerView() {
        
        // Story ID: ContainerView
        let viewController:UIViewController = UIStoryboard(name: "DY", bundle: nil).instantiateViewController(withIdentifier: "ContainerView") as UIViewController
        
        
        self.present(viewController, animated: false, completion: nil)
        
    }
    
    // MainView Controller로 이동
    func moveToMainView() {
        
        // Story ID: MainView
        let viewController:UIViewController = UIStoryboard(name: "MainView", bundle: nil).instantiateViewController(withIdentifier: "MainView") as UIViewController
        
        
        self.present(viewController, animated: false, completion: nil)
    }
    
    // MyPageView Controller 로 이동 
    func moveToMyPageView() {
        
        // Story ID: MyPageView
        
        let viewController:UIViewController = UIStoryboard(name: "MainView", bundle: nil).instantiateViewController(withIdentifier: "MyPageView") as UIViewController
        
        
        self.present(viewController, animated: false, completion: nil)
        
    }
    
    // ProfileEdit View Controller 로 이동
    func moveToProfileEdit() {
        
        // ProfileEdit View Controller 로 이동
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileEdit")
        self.present(vc!, animated: true, completion: nil)
        
    }
    
    // Home View Controller 로 이동
    func moveToHomeVC() {
        
        // Home View Controller 로 이동
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
        self.present(vc!, animated: true, completion: nil)
        
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
        
        let isFormVaild = self.emailTextField.text?.characters.count ?? 0 > 0 && self.nicknameTextField.text?.characters.count ?? 0 > 0 && self.passwordTextField.text?.characters.count ?? 0 > 0 && self.passwordConfirmTextField.text?.characters.count ?? 0 > 0
        
        
        
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
    
    @IBAction func nicknameTextFieldEditingChanged(_ sender: UITextField) {
        
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
