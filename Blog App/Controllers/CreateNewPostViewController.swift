//
//  CreateNewPostViewController.swift
//  Blog App
//
//  Created by Luyện Hà Luyện on 14/06/2023.
//

import UIKit

class CreateNewPostViewController: UITabBarController {

    private let titleField: UITextField = {
       let field = UITextField()
        field.keyboardType = .emailAddress
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.layer.cornerRadius = 10
        field.placeholder = "Tiêu đề..."
        field.autocapitalizationType = .words
        field.autocorrectionType = .yes
        field.backgroundColor = .secondarySystemBackground
        field.layer.masksToBounds = true
        return field
    }()
    private let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .secondarySystemBackground
        textView.isEditable = true
        textView.font = .systemFont(ofSize: 28)
        textView.layer.cornerRadius = 10
        return textView
    }()
    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "photo")
        imageView.backgroundColor = .tertiarySystemBackground
        return imageView
    }()
    private var selectedHeaderImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(titleField)
        view.addSubview(textView)
        view.addSubview(headerImageView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapHeaderImage))
        headerImageView.addGestureRecognizer(tap)
        configureButton()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleField.frame = CGRect(x: 10, y: view.safeAreaInsets.top,
                                  width: view.width - 20, height: 50)
        headerImageView.frame = CGRect(x: 0, y: titleField.bottom + 15,
                                       width: view.width, height: view.width / 1.618)
        textView.frame = CGRect(x: 10, y: headerImageView.bottom + 15,
                                width: view.width - 20, height: (view.width - 20) / 1.618)
    }
    private func configureButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Quay lại",
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Xong",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapDone))
    }
    @objc private func didTapHeaderImage() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
    @objc private func didTapDone() {
        guard let title = titleField.text,
                let body = textView.text,
                let headerImage = selectedHeaderImage,
              let email = UserDefaults.standard.string(forKey: "email"),                !title.trimmingCharacters(in: .whitespaces).isEmpty,
                !body.trimmingCharacters(in: .whitespaces).isEmpty else {
            let alert = UIAlertController(title: "Thêm chi tiết bài viết", message: "Vui lòng nhập tiêu đề, nội dung và chọn ảnh để tiếp tục", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Bỏ qua", style: .cancel, handler: nil))
            present(alert, animated: true)
            
            return
        }
        print("Đang tải lên post...")
        //Upload HeaderImage
        let newPosstId = UUID().uuidString
        StorageManager.shared.uploadBlogHeaderImage(email: email, image: headerImage, postId: newPosstId) { success in
            guard success else {
                return
            }
            StorageManager.shared.downloadUrlForPostHeader(email: email, postId: newPosstId) { url in
                guard let headerURL = url else {
                    DispatchQueue.main.async {
                        //Phản hồi xúc giác
                        HapticsManager.shared.vibrate(for: .success)
                    }
                    return
                }
                let post = BlogPost(identifier: UUID().uuidString, title: title, timestamp: Date().timeIntervalSince1970, headerImageUrl: headerURL, text: body)
                DatabaseManager.shared.insert(blogPost: post, email: email) { [weak self] posted in
                    guard posted else {
                        DispatchQueue.main.async {
                            //Phản hồi xúc giác
                            HapticsManager.shared.vibrate(for: .error)
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        //Phản hồi xúc giác
                        HapticsManager.shared.vibrate(for: .success)
                        self?.didTapCancel()
                    }
                }
            }
        }
    }
}
extension CreateNewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        selectedHeaderImage = image
        headerImageView.image = image
    }
}
