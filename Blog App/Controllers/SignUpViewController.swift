//
//  SignUpViewController.swift
//  Blog App
//
//  Created by Luyện Hà Luyện on 14/06/2023.
//

import UIKit

class SignUpViewController: UITabBarController {

    //Header View
    private let headerView = SignInHeaderView()
    
    private let nameField: UITextField = {
       let field = UITextField()
        field.keyboardType = .emailAddress
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Họ tên"
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    private let emailField: UITextField = {
       let field = UITextField()
        field.keyboardType = .emailAddress
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Địa chỉ email"
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    private let passwordField: UITextField = {
       let field = UITextField()
        field.keyboardType = .emailAddress
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Mật khẩu"
        field.isSecureTextEntry = true
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    private let signUpButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        button.setTitle("Đăng Ký", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Đăng nhập"
        view.backgroundColor = .systemBackground
        view.addSubview(headerView)
        view.addSubview(nameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)
        
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.frame =      CGRect(x: 0, y: view.safeAreaInsets.top,
                                       width: view.width, height: view.height / 4)
        nameField.frame =      CGRect(x: 20, y: headerView.bottom,
                                       width: view.width - 40, height: 50)
        emailField.frame =      CGRect(x: 20, y: nameField.bottom + 10,
                                       width: view.width - 40, height: 50)
        passwordField.frame =   CGRect(x: 20, y: emailField.bottom + 10,
                                       width: view.width - 40, height: 50)
        signUpButton.frame =    CGRect(x: 20, y: passwordField.bottom + 40,
                                       width: view.width - 40, height: 50)
    }
    @objc func didTapSignUp() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty,
              let name = nameField.text, !name.isEmpty else {
                  return
              }
        //Phản hồi xúc giác
        HapticsManager.shared.vibrateForSelection()
        //Create User
        AuthManager.shared.signUp(email: email, password: password) { [weak self] success in
            if success {
                //Update database
                let newUser = User(name: name, email: email, profilePictureRef: nil)
                DatabaseManager.shared.insert(user: newUser) { inserted in
                    guard inserted else {
                        return
                    }
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(name, forKey: "name")
                    DispatchQueue.main.async {
                        let vc = TabBarViewController()
                        vc.modalPresentationStyle = .fullScreen
                        self?.present(vc, animated: true)
                    }
                }
            } else {
                print("Tao taiif khoản không thành công")
            }
            
        }
    }
}
