//
//  ProfileEditViewController.swift
//  WeatherSound
//
//  Created by 정교윤 on 2017. 8. 11..
//  Copyright © 2017년 정교윤. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import SwiftyJSON
import FBSDKLoginKit


class ProfileEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet var mainView: UIView! // 메인 뷰 (리프레쉬용)
    
    
    @IBOutlet weak var stackView: UIStackView!
    
    
    
    @IBOutlet weak var profilePhotoButton: UIButton!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var currentPasswordTextField: UITextField!
    
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    @IBOutlet weak var newPasswordConfirmTextField: UITextField!
    
    @IBOutlet weak var saveProfileButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel! // 닉네임 표시 
    
    @IBOutlet weak var deleteProfileButton: UIButton!
    
    var email:String?   // email (username)
    var pk:Int?         // primary key
    var token:String?   // token
    
    
    
    var changedImage:UIImage? // 사용자가 선택한 이미지
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 프로필 편집 옆에 닉네임 텍스트 붙여서 보여주기 
        
        self.profilePhotoButton.translatesAutoresizingMaskIntoConstraints = true
        
        self.profilePhotoButton.layer.cornerRadius = 80 / 2
        self.profilePhotoButton.layer.borderWidth = 1
        
        
        // 각 필드 초기화 
        self.nicknameTextField.text = ""
        
        self.currentPasswordTextField.text = ""
        self.newPasswordTextField.text = ""
        self.newPasswordConfirmTextField.text = ""
        self.titleLabel.text = ""
        
        if LoginDataCenter.shared.requestIsLogin() == false && LoginDataCenter.shared.myLoginInfo == nil { // 로그아웃상태
            
            self.nicknameTextField.placeholder = ""
            
        } else {
            
            if LoginDataCenter.shared.myLoginInfo != nil { // 로그인 후 앱을 처음 실행하고 있을 때
                
                self.nicknameTextField.placeholder = "기존 닉네임: "+(LoginDataCenter.shared.myLoginInfo?.nickname)!
                
                self.email = LoginDataCenter.shared.myLoginInfo?.email
                self.pk = LoginDataCenter.shared.myLoginInfo?.pk
                self.token = LoginDataCenter.shared.myLoginInfo?.token
                
                
            } else { // 로그인 후 앱을 다시 켰거나 재시작했을 때 (UserDefauls 에 있는 정보 이용)
                
                var dic:[String:Any] = UserDefaults.standard.dictionary(forKey: Authentication.userInfo)!
                
                let username = dic["username"] as? String
                let nickname = dic["nickname"] as? String
                
                self.nicknameTextField.placeholder = "기존 닉네임: "+nickname!
                
                // username (email) 가져오기 
                self.email = username
                
                // pk 가져오기
                self.pk = UserDefaults.standard.integer(forKey: Authentication.pk)
                
                // token 가져오기
                self.token = UserDefaults.standard.string(forKey: Authentication.token)
                
            }
            
        }
        
        setInitialDataAndImage()
        
        // 사용자가 선택한 이미지가 있다면 현재 버튼에 있는 이미지를 사용자가 선택한 이미지로 바꾼다.
        if let image = self.changedImage {
            
            self.profilePhotoButton.setImage(image, for: .normal)
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("------ ViewDidAppear ProfileEditViewController -----")
            
        showLoginStatusAlamofire() // 로그아웃된 상태라면 로그인 페이지를 보여주고 아니면 현재 페이지를 보여준다.
            
        saveProfileButtonActivated() // 아무것도 입력이 안 되었기 때문에 저장 버튼을 비활성화한다.
            
        deleteProfileButtonActivated() // 비밀번호란이 비어있으면 계정 삭제 버튼을 비활성화한다.
            
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
                
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 1...300:
            print(textField.tag)
            self.view.viewWithTag(textField.tag + 100)?.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
            //self.signupRequestFirebase()
            
            // 변경된 사용자 정보 저정하기 (프로필 사진, 닉네임, 비밀번호, 새로운 비밀번호, 확인을 위해 다시 입력한 비밀번호)
            self.performUpdateProfileInfo()
            
        }
        
        return true
    }
    
    func photoActionHandler() {
        print ("action Photo")
        
        
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true // edit된 이미지 가져올 때
        self.present(picker, animated: true, completion: nil)
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            image.withRenderingMode(.alwaysOriginal)
            //image.withRenderingMode(.automatic)
            
            print("setting image")
            
            self.changedImage = image
            
            
        } else{
            
            print("Something went wrong")
            
            return
        }
        
        self.dismiss(animated: true, completion: nil)
        
        
//        print("info://",info)
//        
//        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage else {
//            return
//        }
//        
//        // UIImagePickerControllerCropRect -> crop된 이미지 사이즈 가져올 때
//        // UIImagePickerControllerEditedImage -> edit딘 이미지 가져올 때
//        
//        image.withRenderingMode(.alwaysOriginal) // 이미지 변조가 일어날 경우를 대비해 항상 오리지널 이미지로 셋팅 (틴트 컬러 등에 의해 자동으로 이미지 변환이 일어나기 때문)
//        
//        
//        
//        self.profilePhotoButton.setImage(image, for: .normal)
//        self.profilePhotoButton.clipsToBounds = true
//        
//        // 사진이 로딩되었으므로 플래그를 바꾼다.
//        //self.isProfileImageInsideButton = true
//        
//        print("image upload is done")
//        
//        self.dismiss(animated: true, completion: nil)
        
        print("info://",info)
        
//        /// chcek if you can return edited image that user choose it if user already edit it(crop it), return it as image
//        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
//            
//            editedImage.withRenderingMode(.alwaysOriginal) // 이미지 변조가 일어날 경우를 대비해 항상 오리지널 이미지로 셋팅 (틴트 컬러 등에 의해 자동으로 이미지 변환이 일어나기 때문)
//
//            /// if user update it and already got it , just return it to 'self.imgView.image'
//            
//            self.profilePhotoButton.setImage(editedImage, for: .normal)
//            self.profilePhotoButton.clipsToBounds = true
//            
//            
//            
//            /// else if you could't find the edited image that means user select original image same is it without editing .
//        } else if let orginalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            
//            orginalImage.withRenderingMode(.alwaysOriginal) // 이미지 변조가 일어날 경우를 대비해 항상 오리지널 이미지로 셋팅 (틴트 컬러 등에 의해 자동으로 이미지 변환이 일어나기 때문)
//            
//            /// if user update it and already got it , just return it to 'self.imgView.image'.
//            self.profilePhotoButton.setImage(orginalImage, for: .normal)
//            self.profilePhotoButton.clipsToBounds = true
//            
//            
//        }
//        else {
//            print ("error")
//            return
//        }
//        
//        /// if the request successfully done just dismiss
//        self.dismiss(animated: true, completion: nil)

        
    }

    
    
    func showLoginStatusAlamofire() {
        
        
        // 로그인상태가 아니고 현재 데이터 센터에 값이 비어있다면 로그인 페이지를 띄운다.
        if LoginDataCenter.shared.requestIsLogin() == false && LoginDataCenter.shared.myLoginInfo == nil {
            
            showLoginVC()
            
        } else { // 로그인 상태면 프로필 이미지 보여주기
            
            print("------- after login -----")
            
        }
        
        
        
    }
    
    // 초기 로딩시 사용자 데이터와 이미지 보여주기
    func setInitialDataAndImage() {
        
        // http://s3.ap-northeast-2.amazonaws.com/weather-sound-test-s3-bucket/media/member/basic_profile.png
        
        // 앱을 사용자가 강제로 재시작하거나 백그라운드로 보낸 거 없이 정상적으로 앱이 실행중일 때
        if LoginDataCenter.shared.myLoginInfo != nil {
            
            // 페이스북 로그인 아니라면 email을 보여주고 아니면 nickname을 보여준다.
            if UserDefaults.standard.bool(forKey: Authentication.isFacebookLogin) == false {
                self.titleLabel.text = LoginDataCenter.shared.myLoginInfo?.email
                
                
                
            } else {
                self.titleLabel.text = LoginDataCenter.shared.myLoginInfo?.nickname
                
                self.deleteProfileButton.isHidden = true
                
            }
            
            
            if let urlStr = LoginDataCenter.shared.myLoginInfo?.img_profile, let url = URL(string: urlStr) {
                
                print("img_profile: ",LoginDataCenter.shared.myLoginInfo?.img_profile! ?? "no img_profile")
                self.profilePhotoButton.sd_setImage(with: url, for: .normal, completed: nil)
                
            }
            
            
        } else { // 로그인 상태인데 앱을 다시 시작했을 때
            
            // UserDefaults로부터 MyLoginInfo 불러와서 이미지 URL 가져와서 보여주기
            
            var dic:[String:Any]?
            
            dic = UserDefaults.standard.dictionary(forKey: Authentication.userInfo)
            
            if dic != nil {
                
                if UserDefaults.standard.bool(forKey: Authentication.isFacebookLogin) == false {
                    
                    self.titleLabel.text = dic?["username"] as? String
                    
                } else {
                    
                    self.titleLabel.text = dic?["nickname"] as? String
                    
                    self.deleteProfileButton.isHidden = true
                    
                }
                
                
                if let urlStr = dic?["img_profile"] as? String, let url = URL(string: urlStr) {
                    
                    print("img_profile: ",dic?["img_profile"]! ?? "no img_profile")
                    self.profilePhotoButton.sd_setImage(with: url, for: .normal, completed: nil)
                    
                }
                
            }
            
            
        }

        
    }
    
    
    
    func showLoginVC() {
        
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Login") {
            
            print("login page")
            
            self.present(viewController, animated: true, completion: nil)
        }
        
        
    }
    
    // 프로필 정보 업데이트 - Multipart 기반 데이터로 처리
    func updateProfileInfo(pk:Int, token:String) {
        
        var isParameterNeeded:Bool = false
        
        let headers: HTTPHeaders = [
            "Authorization": "Token "+token
        ]
        
        var parameters: Parameters?
        
        // 페이스북 로그인인 경우 - 프로필 사진과 닉네임만 가지고 정보를 변경한다.
        if UserDefaults.standard.bool(forKey: Authentication.isFacebookLogin) == true {
            
            if self.nicknameTextField.text != "" {
                isParameterNeeded = true
                parameters = ["nickname": self.nicknameTextField.text!]
            }
            
        } else { // 이메일/비밀번호 로그인인 경우
            
            // 케이스 별로 parameters를 완성
            // 1. 아무것도 입력안했을 경우 프로필 사진에 있는 이미지파일만 업로드하겠다
            if self.nicknameTextField.text == "" &&
                self.currentPasswordTextField.text == "" &&
                self.newPasswordTextField.text == "" &&
                self.newPasswordConfirmTextField.text == "" {
                
                print("case 1")
                
            }
            // 2. 닉네임만 입력했을 경우 변경할 데이터는 사진에 있는 이미지파일 업로드하고 닉네임 변경
            if self.nicknameTextField.text != "" &&
                self.currentPasswordTextField.text == "" &&
                self.newPasswordTextField.text == "" &&
                self.newPasswordConfirmTextField.text == "" {
                
                print("case 2")
                
                isParameterNeeded = true
                parameters = ["nickname": self.nicknameTextField.text!]
                
            }
            
            // 3. 닉네임, 기존 비밀번호, 새로운 비밀번호, 확인을 위해 다시 입력한 새로운 비밀번호까지 입력한 경우 이미지 파일 업로드하고 닉네임과 비밀번호를 변경
            if self.nicknameTextField.text != "" &&
                self.currentPasswordTextField.text != "" &&
                self.newPasswordTextField.text != "" &&
                self.newPasswordConfirmTextField.text != "" {
                
                print("case 3")
                
                isParameterNeeded = true
                parameters = ["nickname": self.nicknameTextField.text!,
                              "password": self.currentPasswordTextField.text!,
                              "new_password1":self.newPasswordTextField.text!,
                              "new_password2":self.newPasswordConfirmTextField.text!]
                
            }

            
        }
        

        // http://www.weather-sound.com/api/member/profile/12/edit/ 
        
        let url:String = Authentication.baseUserInfoURL + String(pk) + "/edit/"
        
        Alamofire.upload(
            
            multipartFormData: { multipartFormData in
                
                // 그림파일 append
                if let image = self.profilePhotoButton.image(for: .normal) {
                    
                    print("image uploaded")
                    
                    let imageData = UIImageJPEGRepresentation(image, 0.7)
                    multipartFormData.append(imageData!, withName: "img_profile", fileName: "photo.jpg", mimeType: "jpg/png")
                }
                
                if isParameterNeeded == true { // 파라메터가 있다면
                    
                    // 스트링 값으로 구성된 파라메터 append
                    for (key, value) in parameters! {
                        if value is String || value is Int {
                            multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                        }
                    }

                }
                
                
                
        },
            to: url,
            method: .put,
            headers: headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        
                        //response.response?.statusCode
                        
                        // 202 면 성공 
                        
                        print("Status Code: ",response.response?.statusCode ?? "no status code")
                        
                        // 로그인 리퀘스트 함수를 호출
                        let statusCode = (response.response?.statusCode)!
                        if statusCode == 202 { // 프로필 변경 성공 (202 Accepted)
                            
                            // myLoginInfo 및 UserDefaults 정보 전부 업데이트 
                            if ((response.result.value) != nil) {
                                
                                let json = JSON(response.result.value!)
                                
                                print("Profile UpdateJSON: ",json)
                                
                                if json.dictionaryObject != nil {
                                    
                                    if LoginDataCenter.shared.myLoginInfo != nil {
                                        
                                        LoginDataCenter.shared.updateMyLoginInfo(with: json, token: self.token!)
                                        
                                    } else {
                                        
                                        LoginDataCenter.shared.parseMyLoginInfo(with: json)
                                        LoginDataCenter.shared.myLoginInfo?.token = self.token
                                        
                                    }
                                    
                                    LoginDataCenter.shared.saveMyLoginInfoInUserDefault(myLoginInfo: LoginDataCenter.shared.myLoginInfo!)
                                
                                    // 프로필 정보 변경 성공
                                    // OK 를 눌렀을 때 전체 뷰가 리프레쉬된다.
                                    self.displayProfileUpdateConfirmMessageAndRefreshThisView(vc: self, title: "Profile Update Success", messageToDisplay: json["datail"].stringValue) // detail 오타
                                    
                                    
                                } else {
                                    
                                    // 프로필 정보 변경 에러
                                    CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Profile Update Error", messageToDisplay: "Unknown Error")
                                    
                                }
                                
                                
                                
                            } else {
                                
                                // 프로필 정보 변경 에러
                                CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Profile Update Error", messageToDisplay: "Unknown Error")
                                
                            }
                            
                            
                            
                        } else { // error 발생으로 간주
                            
                            if ((response.result.value) != nil) {
                                
                                
                                let json = JSON(response.result.value!)
                                
                                
                                if json.dictionaryObject != nil {
                                    
                                    // 서버에서 받아서 메시지 뿌려줌
                                    CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Error", messageToDisplay: json["datail"].stringValue) // detail 오타
                                    
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
    
    // 프로필 업데이트 성공시 나타나는 알럿 메시지 보여주는 함수 - OK를 누르면 현재 뷰를 리프레쉬한다.
    func displayProfileUpdateConfirmMessageAndRefreshThisView(vc: UIViewController, title: String, messageToDisplay: String)
    {
        let alertController = UIAlertController(title: title, message: messageToDisplay, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            
            // Code in this block will trigger when OK button tapped.
            print("OK button tapped");
            
            // 현재 뷰 리프레쉬 
            self.mainView.setNeedsDisplay()
            
        }
        
        alertController.addAction(OKAction)
        
        vc.present(alertController, animated: true, completion:nil)
        
    }

    
    // 계정 삭제 - 토큰, PK, username(토큰, PK, 이메일 앱 내부에 저장), password(비밀번호 => 본인이 직접 타이핑)
    // 삭제와 동시에 로그온 페이지로 이동해야 됨 => 로그아웃과 마찬가지로 모든 데이터 초기화
    func deleteAccountInfo(email:String, pk:Int, token:String) {
        
        let headers: HTTPHeaders = [
            "Authorization": "Token "+token,
            "Accept": "application/json"
        ]
        
        let url:String = Authentication.baseUserInfoURL + String(pk) + "/edit/"
        
        // 202 accepted - 성공
        
        
        let loginParameters: Parameters = [
            "username": email,
            "password": self.currentPasswordTextField.text!
        ]
        
        // 삭제 처리 후 데이터 초기화 후 로그인 페이지로 이동
        Alamofire.request(url, method: .delete, parameters: loginParameters, encoding: JSONEncoding.prettyPrinted, headers: headers).responseJSON { (response) in
            
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                print("JSON: \(json)")
                
                // statusCode가 202이 아니라면 에러 메시지를 뿌리고 롤백한다.
                let statusCode = (response.response?.statusCode)!
                print("...HTTP code: \(statusCode)")
                
                if statusCode == 202 { // 삭제 성공 -> 모든 데이터 초기화 후 로그온 뷰로 이동
                    
                    print(json["detail"].stringValue)
                    
                    self.displayAccountDeleteConfirmMessageAndBackToLoginView(vc: self, title: "Account Delete Success", messageToDisplay: json["detail"].stringValue)
                    
                } else { // 삭제 실패
                    
                    print(json["detail"].stringValue)
                    
                    self.displayAccountDeleteFailMessageAndBackToLoginView(vc: self, title: "Account Delete Error", messageToDisplay: json["detail"].stringValue)
                    
                }
                
                
                break
            case .failure(let error):
                
                print(error)
                
                //CommonLibraries.sharedFunc.displayAlertMessageAndDissmiss(vc: self, title: "Error", messageToDisplay: error.localizedDescription)
                
                self.displayAccountDeleteFailMessageAndBackToLoginView(vc: self, title: "Account Delete Error", messageToDisplay: error.localizedDescription)
                
                break
            }
            
            
        }
        

        
    }
    
    // 계정 삭제 성공했을 때 (토큰이 유효할 때) => 로그아웃 처리하고 Login 화면을 보여준다.
    func displayAccountDeleteConfirmMessageAndBackToLoginView(vc: UIViewController, title: String, messageToDisplay: String)
    {
        let alertController = UIAlertController(title: title, message: messageToDisplay, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            
            // Code in this block will trigger when OK button tapped.
            print("OK button tapped");
            
            // pk 초기화 (UserDefaults)
            UserDefaults.standard.setValue(nil, forKey: Authentication.pk)
            
            // token 초기화 (UserDefaults)
            UserDefaults.standard.setValue(nil, forKey: Authentication.token)
            
            // UserDefaults에 저장된 userInfo 초기화
            LoginDataCenter.shared.initializeUserInfoInUserDefault()
            
            // 로그온 상태 false로 셋팅
            UserDefaults.standard.setValue(false, forKey: Authentication.isLoginSucceed)
            
            self.showLoginVC()
            
        }
        
        alertController.addAction(OKAction)
        
        vc.present(alertController, animated: true, completion:nil)
        
    }
    
    // 계정 삭제 실패했을 때 (토큰이 유효하지 않을 때) -> 강제 로그아웃처리하고 Login 화면을 보여준다.
    func displayAccountDeleteFailMessageAndBackToLoginView(vc: UIViewController, title: String, messageToDisplay: String)
    {
        let alertController = UIAlertController(title: title, message: messageToDisplay, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            
            // Code in this block will trigger when OK button tapped.
            print("OK button tapped");
            
            // pk 초기화 (UserDefaults)
            UserDefaults.standard.setValue(nil, forKey: Authentication.pk)
            
            // token 초기화 (UserDefaults)
            UserDefaults.standard.setValue(nil, forKey: Authentication.token)
            
            // UserDefaults에 저장된 userInfo 초기화
            LoginDataCenter.shared.initializeUserInfoInUserDefault()
            
            // 로그온 상태 false로 셋팅
            UserDefaults.standard.setValue(false, forKey: Authentication.isLoginSucceed)
            
            self.showLoginVC()
            
        }
        
        alertController.addAction(OKAction)
        
        vc.present(alertController, animated: true, completion:nil)
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func touchUpInsideProfilePhotoButton(_ sender: UIButton) {
        
        // 사진 선택창 띄우기
        photoActionHandler()
        
    }
    
    @IBAction func touchUpInsideBackButton(_ sender: UIButton) {
        
        //UserDefaults.standard.setValue(true, forKey: Authentication.isLoginSucceed)
        
        self.dismiss(animated: false, completion: nil)
        
        //self.navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func touchUpInsideLogoutButton(_ sender: UIButton) {
        
        logoutFromBackendServer(with: self.token!)
        
    }
        
    @IBAction func nicknameTextFieldEditingChanged(_ sender: UITextField) {
        
        saveProfileButtonActivated()
        
    }
    
    @IBAction func currentPasswordTextFieldEditingChanged(_ sender: UITextField) {
        
        saveProfileButtonActivated()
        deleteProfileButtonActivated()
        
    }
    
    @IBAction func newPasswordTextFieldEditingChanged(_ sender: UITextField) {
        
        saveProfileButtonActivated()
        
    }
    
    @IBAction func newPasswordConfirmTextFieldEditingChanged(_ sender: UITextField) {
        
        saveProfileButtonActivated()
        
    }
    
    // 변경된 사용자 정보 저장하기 버튼 클릭 (프로필 사진, 닉네임, 비밀번호, 새로운 비밀번호, 확인을 위해 다시 입력한 비밀번호)
    @IBAction func touchUpInsideSaveProfileButton(_ sender: UIButton) {
        
        performUpdateProfileInfo()
    }
    
    // 변경된 사용자 정보 저장하기 동작 처리 => 알럿 메시지 띄워서 사용자가 OK 버튼 눌렀을 때만 처리 
    func performUpdateProfileInfo() {
        
        let alertController = UIAlertController(title: "Profile Update Confirmation", message: "프로필 정보를 이대로 변경하시겠습니까?", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            
            self.updateProfileInfo(pk: self.pk!, token: self.token!)
            
        }
        let CANCELAction = UIAlertAction(title: "CANCEL", style: .default) { (action:UIAlertAction!) in
            
            print("updating profile is cancelled")
            
        }
        
        
        alertController.addAction(OKAction)
        alertController.addAction(CANCELAction)
        
        self.present(alertController, animated: true, completion:nil)
        
        
    }
    
    // 계정 삭제 버튼 클릭
    @IBAction func touchUpInsideDeleteButton(_ sender: UIButton) {
        
        performDeleteAccountInfo()
    }
    

    // 변경된 사용자 정보 저장하기 동작 처리 => 알럿 메시지 띄워서 사용자가 OK 버튼 눌렀을 때만 처리
    func performDeleteAccountInfo() {
        
        let alertController = UIAlertController(title: "Account Delete Confirmation", message: "계정 정보를 이대로 삭제하시겠습니까?", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            
            self.deleteAccountInfo(email:self.email!, pk: self.pk!, token: self.token!)
            
        }
        let CANCELAction = UIAlertAction(title: "CANCEL", style: .default) { (action:UIAlertAction!) in
            
            print("deleting account is cancelled")
            
        }
        
        
        alertController.addAction(OKAction)
        alertController.addAction(CANCELAction)
        
        self.present(alertController, animated: true, completion:nil)
        
        
    }
    
    
    // 로그아웃 처리 로직
    func logoutFromBackendServer(with token:String) {
        
        //UserDefaults.standard.setValue(true, forKey: Authentication.isFacebookLogin)
        
        let headers: HTTPHeaders = [
            "Authorization": "Token "+token,
            "Accept": "application/json"
        ]
        
        
        
        Alamofire.request(Authentication.logoutURL, headers: headers)
            .responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    
                    // 데이터 초기화
                    LoginDataCenter.shared.myLoginInfo = nil
                    
                    print(json)
                    
                    // statusCode가 200이 아니라면 에러 메시지를 뿌리고 롤백한다.
                    let statusCode = (response.response?.statusCode)!
                    print("...HTTP code: \(statusCode)")
                    
                    if statusCode == 202 { // 로그아웃 성공
                        
                        print(json["detail"].stringValue)
                        
                        self.displayLogoutConfirmMessageAndBackToLoginView(vc: self, title: "Logout Success", messageToDisplay: json["detail"].stringValue)
                        
                        
                        
                    } else {
                        
                        print(json["detail"].stringValue)
                        
                        self.displayLogoutFailMessageAndBackToLoginView(vc: self, title: "Logout Error", messageToDisplay: json["detail"].stringValue)
                        
                    }
                    
                    break
                case .failure(let error):
                    
                    
                    
                    print(error)
                    self.displayLogoutFailMessageAndBackToLoginView(vc: self, title: "Logout Error", messageToDisplay: error.localizedDescription)
                    
                    break
                }
                
                
                
        }
        
        
        
    }
    
    // 로그아웃 성공했을 때 (토큰이 유효할 때) => 로그아웃 처리하고 Login 화면을 보여준다.
    func displayLogoutConfirmMessageAndBackToLoginView(vc: UIViewController, title: String, messageToDisplay: String)
    {
        let alertController = UIAlertController(title: title, message: messageToDisplay, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            
            // Code in this block will trigger when OK button tapped.
            print("OK button tapped");
            
            // pk 초기화 (UserDefaults)
            UserDefaults.standard.setValue(nil, forKey: Authentication.pk)
            
            // token 초기화 (UserDefaults)
            UserDefaults.standard.setValue(nil, forKey: Authentication.token)
            
            // UserDefaults에 저장된 userInfo 초기화
            LoginDataCenter.shared.initializeUserInfoInUserDefault()
            
            // 로그온 상태 false로 셋팅
            UserDefaults.standard.setValue(false, forKey: Authentication.isLoginSucceed)
            
            // 페이스북 로그온 상태 false로 셋팅
            UserDefaults.standard.setValue(false, forKey: Authentication.isFacebookLogin)
            
            // facebook 로그온으로 되어있다면 facebook 로그아웃을 시킨다.
            if UserDefaults.standard.bool(forKey: Authentication.isFacebookLogin) == true {
                
                print("------ facebook logout -----")
                
                UserDefaults.standard.setValue(false, forKey: Authentication.isFacebookLogin)
                FBSDKLoginManager().logOut()
                
            }
            
            // 로그인 화면으로 이동
            //self.showLoginVC()
            
            // Container View Controller로 이동
            self.moveToContainerView()
            
        }
        
        alertController.addAction(OKAction)
        
        vc.present(alertController, animated: true, completion:nil)
        
    }
    
    // 로그아웃 실패했을 때 (토큰이 유효하지 않을 때) -> 로그아웃처리하고 Login 화면을 보여준다.
    func displayLogoutFailMessageAndBackToLoginView(vc: UIViewController, title: String, messageToDisplay: String)
    {
        let alertController = UIAlertController(title: title, message: messageToDisplay, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            
            // Code in this block will trigger when OK button tapped.
            print("OK button tapped");
            
            // pk 초기화 (UserDefaults)
            UserDefaults.standard.setValue(nil, forKey: Authentication.pk)
            
            // token 초기화 (UserDefaults)
            UserDefaults.standard.setValue(nil, forKey: Authentication.token)
            
            // UserDefaults에 저장된 userInfo 초기화
            LoginDataCenter.shared.initializeUserInfoInUserDefault()
            
            // 로그온 상태 false로 셋팅
            UserDefaults.standard.setValue(false, forKey: Authentication.isLoginSucceed)
            
            // facebook 로그온으로 되어있다면 facebook 로그아웃을 시킨다.
            if UserDefaults.standard.bool(forKey: Authentication.isFacebookLogin) == true {
                
                print("------ facebook logout -----")
                
                UserDefaults.standard.setValue(false, forKey: Authentication.isFacebookLogin)
                FBSDKLoginManager().logOut()
                
            }
            
            // 로그인 화면으로 이동
            //self.showLoginVC()
            
            // Container View Controller로 이동
            self.moveToContainerView()
            
        }
        
        alertController.addAction(OKAction)
        
        vc.present(alertController, animated: true, completion:nil)
    }
    
    // Container View Controller로 이동
    func moveToContainerView() {
        
        // Story ID: ContainerView
        let viewController:UIViewController = UIStoryboard(name: "DY", bundle: nil).instantiateViewController(withIdentifier: "ContainerView") as UIViewController
        
        
        self.present(viewController, animated: false, completion: nil)
        
    }
    
    // 저장 버튼 비활성화할 지 활성화할 지 판단하는 로직
    func saveProfileButtonActivated() {
        
        // 케이스 구분 
        // 프로필 사진은 항상 이미지가 들어가있으므로 제외 
        // 모든 란이 비어있을 경우 false
        // 닉네임만 입력했을 경우 true 
        // 닉네임과 패스워드 입력했을 경우 false
        // 닉네임과 패스워드, 새로운 패스워드 입력했을 경우 false 
        // 닉네임과, 패스워드, 새로운 패스워드, 확인 패스워드 입력했을 경우 true 
        // 패스워드만 입력했을 경우 false
        // 패스워드, 새로운 패스워드 입력했을 경우 false
        // 패스워드, 새로운 패스워드, 확인 패스워드 입력했을 경우 true
        
        
        let isFormVaild = self.nicknameTextField.text?.characters.count ?? 0 > 0 || (self.currentPasswordTextField.text?.characters.count ?? 0 > 0 && self.newPasswordTextField.text?.characters.count ?? 0 > 0 && self.newPasswordConfirmTextField.text?.characters.count ?? 0 > 0)
        
        
        
        if isFormVaild {
            self.saveProfileButton.isEnabled = true
            self.saveProfileButton.backgroundColor = UIColor.rgbColor(74, 144, 226)
            
        } else {
            self.saveProfileButton.isEnabled = false
            self.saveProfileButton.backgroundColor = UIColor.rgbColor(149, 204, 244)
        }
        
    }

    // 계정 삭제 버튼 비활성화할 지 활성화할 지 판단하는 로직 
    func deleteProfileButtonActivated() {
        
        let isFormVaild = self.currentPasswordTextField.text?.characters.count ?? 0 > 0
        
        if isFormVaild {
            self.deleteProfileButton.isEnabled = true
            self.deleteProfileButton.backgroundColor = UIColor.rgbColor(74, 144, 226)
            
        } else {
            self.deleteProfileButton.isEnabled = false
            self.deleteProfileButton.backgroundColor = UIColor.rgbColor(149, 204, 244)
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
