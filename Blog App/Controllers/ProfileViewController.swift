//
//  ProfileViewController.swift
//  Blog App
//
//  Created by Luyện Hà Luyện on 14/06/2023.
//

import UIKit
import MobileCoreServices

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var user: User?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PostPreviewTableViewCell.self,
                            forCellReuseIdentifier: PostPreviewTableViewCell.identifider)
        return tableView
    }()
    
    let currentEmail: String
    
    init(currentEmail: String) {
        self.currentEmail = currentEmail
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        setUpSignOutButton()
        title = "Profile"
        view.backgroundColor = .systemBackground
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.fetchPosts()
        }
    }
    private func setUpTable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        setUpTableHeader()
        fetchProfileData()
    }
    private func setUpTableHeader(profilePhoToRef: String? = nil, name: String? = nil) {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.width / 1.618))
        headerView.backgroundColor = .systemBlue
        headerView.isUserInteractionEnabled = true
        headerView.clipsToBounds = true
        tableView.tableHeaderView = headerView
        
        let profilePhoto = UIImageView(image: UIImage(systemName: "person.circle"))
        profilePhoto.tintColor = .white
        profilePhoto.contentMode = .scaleAspectFit
        profilePhoto.isUserInteractionEnabled = true
        profilePhoto.frame = CGRect(x: (view.width - (view.width / 4)) / 2,
                                    y: (headerView.height - (view.width / 4)) / 2.5,
                                    width: (view.width / 4),
                                    height: (view.width / 4)
        )
        profilePhoto.backgroundColor = .white
        profilePhoto.layer.masksToBounds = true
        profilePhoto.layer.cornerRadius = profilePhoto.width / 2
        headerView.addSubview(profilePhoto)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfiePhoto))
        profilePhoto.addGestureRecognizer(tap)
        
        let emailLabel = UILabel(frame: CGRect(x: 20, y: profilePhoto.bottom + 10,
                                               width: view.width - 40, height: 100))
        headerView.addSubview(emailLabel)
        emailLabel.text = currentEmail
        emailLabel.textAlignment = .center
        emailLabel.textColor = .white
        emailLabel.font = .systemFont(ofSize: 20, weight: .bold)
        
        if let name = name {
            title = name
        }
        if let ref = profilePhoToRef {
            StorageManager.shared.downloadUrlForProfilePicture(path: ref) { url in
                guard let url = url else {
                    return
                }
                let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                    guard let data = data else {
                        return
                    }
                    DispatchQueue.main.async {
                        profilePhoto.image = UIImage(data: data)
                    }
                }
                task.resume()
            }
        }
    }
    @objc private func didTapProfiePhoto() {
        guard let myEmail = UserDefaults.standard.string(forKey: "email"),
                    myEmail == currentEmail else {
            return
        }
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    private func fetchProfileData() {
        DatabaseManager.shared.getUser(email: currentEmail) { [weak self] user in
            guard let user = user else {
                return
            }
            self?.user = user
            DispatchQueue.main.async {
                self?.setUpTableHeader(profilePhoToRef: user.profilePictureRef, name: user.name)
            }
        }
    }
    private func setUpSignOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Đăng xuất",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSignOut)
        )
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    @objc private func didTapSignOut() {
        let sheet = UIAlertController(title: "Đăng xuẩt", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Bỏ qua", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Đăng xuẩt", style: .destructive, handler: { _ in
            AuthManager.shared.signOut { [weak self] success in
                if success {
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(nil, forKey: "email")
                        UserDefaults.standard.set(nil, forKey: "name")
                        //Khi nào có IAP
                        UserDefaults.standard.set(false, forKey: "premium")
                        let signInVC = SignInViewController()
                        signInVC.navigationItem.largeTitleDisplayMode = .always
                        let navVC = UINavigationController(rootViewController: signInVC )
                        navVC.navigationBar.prefersLargeTitles = true
                        navVC.modalPresentationStyle = .fullScreen
                        self?.present(navVC, animated: true)
                    }
                }
            }
        }))
        present(sheet, animated: true)
    }
    private var posts: [BlogPost] = []
    
    private func fetchPosts() {
        guard let email = user?.email else {
            return
        }
        print("Tìm và nạp ...")
        DatabaseManager.shared.getPosts(for: email) { [weak self] posts in
            self?.posts = posts
            print("Tìm thấy \(posts.count) bài viết")
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostPreviewTableViewCell.identifider, for: indexPath) as? PostPreviewTableViewCell else {
            fatalError()
        }
        cell.configure(with: .init(title: post.title, imageUrl: post.headerImageUrl))
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Phản hồi xúc giác
        HapticsManager.shared.vibrateForSelection()
        //Khi nào có IAP
//        var isOwnedByCurrentUser = false
//        if let email = UserDefaults.standard.string(forKey: "email"){
//            isOwnedByCurrentUser = email == currentEmail
//        }
//        if !isOwnedByCurrentUser {
//            if IAPManager.shared.canViewPost {
//                let vc = ViewPostViewController(post: posts[indexPath.row],
//                                                isOwnedByCurrentUser: isOwnedByCurrentUser)
//                vc.navigationItem.largeTitleDisplayMode = .never
//                vc.title = "Post"
//                navigationController?.pushViewController(vc, animated: true)
//            }
//        } else {
//            let vc = ViewPostViewController(post: posts[indexPath.row],
//                                        isOwnedByCurrentUser: isOwnedByCurrentUser)
            let vc = ViewPostViewController(post: posts[indexPath.row])
            vc.navigationItem.largeTitleDisplayMode = .never
            vc.title = posts[indexPath.row].title
            navigationController?.pushViewController(vc, animated: true)
//        }
    }
}
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        StorageManager.shared.uploadUserProfilePicture(email: currentEmail, image: image) { [weak self] success in
            guard let strongSelf = self else {
                return
            }
            if success {
                DatabaseManager.shared.updateProfilePhoto(email: strongSelf.currentEmail) { update in
                    guard update else {
                        return
                    }
                    DispatchQueue.main.async {
                        strongSelf.fetchProfileData()
                    }
                }
            }
        }
    }
}
