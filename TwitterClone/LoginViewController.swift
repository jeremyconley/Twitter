//
//  LoginViewController.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 1/31/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        return textField
    }()
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    //Sign up text fields
    let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.borderStyle = .roundedRect
        return textField
    }()
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Full name"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    let loginButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let signupButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let navBar = UINavigationBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = twitterBlue
        setupViews()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view.
    }
    
    func handleDismissKeyboard(){
        self.view.resignFirstResponder()
    }

    
    func setupViews(){
        self.view.addSubview(navBar)
        self.view.addSubview(emailTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(nameTextField)
        self.view.addSubview(usernameTextField)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        nameTextField.delegate = self
        usernameTextField.delegate = self
        
        self.view.addSubview(loginButton)
        self.view.addSubview(signupButton)
        
        nameTextField.isHidden = true
        usernameTextField.isHidden = true
        
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        signupButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        
        navBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/5)
        navBar.barTintColor = .white
        self.navigationItem.title = "Login"
        navBar.pushItem(self.navigationItem, animated: true)
        
        
        navBar.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        emailTextField.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 75, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        passwordTextField.anchor(emailTextField.bottomAnchor, left: emailTextField.leftAnchor, bottom: nil, right: emailTextField.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        nameTextField.anchor(passwordTextField.bottomAnchor, left: emailTextField.leftAnchor, bottom: nil, right: emailTextField.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        usernameTextField.anchor(nameTextField.bottomAnchor, left: emailTextField.leftAnchor, bottom: nil, right: emailTextField.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        loginButton.anchor(usernameTextField.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 20, leftConstant: 40, bottomConstant: 0, rightConstant: 40, widthConstant: 135, heightConstant: 35)
        signupButton.anchor(loginButton.bottomAnchor, left: loginButton.leftAnchor, bottom: nil, right: loginButton.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 135, heightConstant: 35)
        
    }
    
    func login(){
        // Sign In with credentials.
        let email = emailTextField.text
        let password = passwordTextField.text
        FIRAuth.auth()?.signIn(withEmail: email!, password: password!) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func signUp(){
        //Open username and name textfields
        nameTextField.isHidden = false
        usernameTextField.isHidden = false
        
        if usernameTextField.text == "" || nameTextField.text == "" {
            
        } else {
            let email = emailTextField.text
            let password = passwordTextField.text
            FIRAuth.auth()?.createUser(withEmail: email!, password: password!) { (user, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                } else {
                    let userId = (user?.uid)! as String
                    let newUser = User(name: self.nameTextField.text!, username: self.usernameTextField.text!, userId: userId, email: self.emailTextField.text!, profileImageDownloadUrl: "", coverImageDownloadUrl: "")
                    let ref = FIRDatabase.database().reference(withPath: "users")
                    ref.childByAutoId().setValue(newUser.toAnyObject())
                    self.setDisplayName(user)
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
        }
    }
    
    func setDisplayName(_ user: FIRUser?) {
        let changeRequest = user?.profileChangeRequest()
        changeRequest?.displayName = usernameTextField.text
        changeRequest?.commitChanges(){ (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
