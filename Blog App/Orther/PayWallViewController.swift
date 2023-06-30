//
//  PayWallViewController.swift
//  Blog App
//
//  Created by Luyện Hà Luyện on 16/06/2023.
//

import UIKit

class PayWallViewController: UIViewController {

    private let header = PayWallHeaderView()
    // Giá cả và thông tin sản phẩm
    private let heroView = PayWallDescriptionView()
    // Nút CTA
    private let buyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Đăng ký", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    private let restoreButton: UIButton = {
        let button = UIButton()
        button.setTitle("Hoàn lại", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    //Điều khoản dịch vụ
    private let termsView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.textAlignment = .center
        textView.textColor = .secondaryLabel
        textView.font = .systemFont(ofSize: 14)
        textView.text = "Đây là một gói tự động gia hạn. Nó sẽ được thay đổi thành tài khoản iTunes của bạn trước mỗi kỳ thanh toán. Bạn có thể hủy bất kỳ lúc nào bằng cách vào phần cài đặt của mình > Đăng ký > Khôi phục giao dịch mua nếu đã đăng ký trước đó"
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tài khoản Premium"
        view.backgroundColor = .systemBackground
        view.addSubview(header)
        view.addSubview(buyButton)
        view.addSubview(restoreButton)
        view.addSubview(termsView)
        view.addSubview(heroView)
        setUpCloseButton()
        setUpButtons()
        heroView.backgroundColor = .systemBackground
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        header.frame = CGRect(x: 0, y: view.safeAreaInsets.top,
                              width: view.width, height: view.height / 3)
        termsView.frame = CGRect(x: 10, y: view.height - 100,
                              width: view.width - 20, height: 100)
        restoreButton.frame = CGRect(x: 25, y: termsView.top - 70,
                              width: view.width - 50, height: 50)
        buyButton.frame = CGRect(x: 25, y: restoreButton.top - 60,
                              width: view.width - 50, height: 50)
        heroView.frame = CGRect(x: 0, y: header.bottom,
                                width: view.width, height: buyButton.top - view.safeAreaInsets.top - header.height
        )
    }
    private func setUpButtons() {
//        buyButton.addTarget(self, action: #selector(didTapSubcribe), for: .touchUpInside)
//        restoreButton.addTarget(self, action: #selector(didTapRestore), for: .touchUpInside)
        buyButton.addTarget(self, action: #selector(didTapSubcribeButNoIAP), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(didTapRestoreButNoIAP), for: .touchUpInside)
    }
    @objc private func didTapRestoreButNoIAP() {
        print("ĐÃ ẤN NÚT HOÀN TIỀN")
    }
    @objc private func didTapSubcribeButNoIAP() {
        print("ĐÃ ẤN NÚT MUA PREMIUM")
    }
    @objc private func didTapRestore() {
        IAPManager.shared.restorePurchases { [weak self] success in
            print("Hoàn tiền: \(success)")
            DispatchQueue.main.async {
                if success {
                    self?.dismiss(animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Hoàn tiền không thành công",
                                                  message: "Chúng tôi không thể hoàn tất giao dịch",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Bỏ qua", style: .cancel, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    @objc private func didTapSubcribe() {
        IAPManager.shared.fetechPackage { package in
            guard let package = package else {
                return
            }
            IAPManager.shared.subscribe(package: package) { success in
                print("purchase: \(success)")
                DispatchQueue.main.async {
                    if success {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController(title: "Đăng ký không thành công",
                                                      message: "Chúng tôi không thể hoàn tất giao dịch",
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Bỏ qua", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        
    }
    private func setUpCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                            target: self,
                                                            action: #selector(didTapClose))
    }
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
}
