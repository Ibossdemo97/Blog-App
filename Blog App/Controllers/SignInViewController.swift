//
//  SignInViewController.swift
//  Blog App
//
//  Created by Luyện Hà Luyện on 14/06/2023.
//

import UIKit

class SignInViewController: UITabBarController {

    //Header View
    private let headerView = SignInHeaderView()
    
    private let emailField: UITextField = {
       let field = UITextField()
        field.keyboardType = .emailAddress
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
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Mật khẩu"
        field.isSecureTextEntry = true
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    private let signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Đăng nhập", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    private let signUpButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        button.setTitle("Đăng ký", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Đăng nhập"
        view.backgroundColor = .systemBackground
        view.addSubview(headerView)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
//        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
////            if !IAPManager.shared.isPremium() {
//            if isPremium != false {
//                let vc = PayWallViewController()
//                let nav = UINavigationController(rootViewController: vc)
//                self.present(nav, animated: true, completion: nil)
//            }
//        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.frame =      CGRect(x: 0, y: view.safeAreaInsets.top,
                                       width: view.width, height: view.height / 4)
        emailField.frame =      CGRect(x: 20, y: headerView.bottom,
                                       width: view.width - 40, height: 50)
        passwordField.frame =   CGRect(x: 20, y: emailField.bottom + 10,
                                       width: view.width - 40, height: 50)
        signInButton.frame =    CGRect(x: 20, y: passwordField.bottom + 10,
                                       width: view.width - 40, height: 50)
        signUpButton.frame =    CGRect(x: 20, y: signInButton.bottom + 40,
                                       width: view.width - 40, height: 50)
    }
    @objc func didTapSignIn() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            return
        }
        //Phản hồi xúc giác
        HapticsManager.shared.vibrateForSelection()
        AuthManager.shared.signIn(email: email, password: password) { [weak self] success in
            guard success else {
                return
            }
            // Khi nào có IAP
            // Cập nhật trạng thái đăng ký cho người dùng mới đăng nhập
            IAPManager.shared.getSubscriptionStatus(completion: nil)
            DispatchQueue.main.async {
                UserDefaults.standard.set(email, forKey: "email")
                let vc = TabBarViewController()
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: true)
            }
        }
    }
    @objc func didTapSignUp() {
        let vc = SignUpViewController()
        vc.title = "Đăng ký"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }
}
