//
//  ViewController.swift
//  Blog App
//
//  Created by Luyện Hà Luyện on 14/06/2023.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let composeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35, weight: .medium)), for: .normal)
        button.layer.cornerRadius = 40
        button.layer.shadowColor = UIColor.label.cgColor
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = 10
        return button
    }()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PostPreviewTableViewCell.self,
                            forCellReuseIdentifier: PostPreviewTableViewCell.identifider)
        return tableView
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(composeButton)
        tableView.delegate = self
        tableView.dataSource = self
        composeButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
        fetchAllPosts()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        composeButton.frame = CGRect(x: view.frame.width - 80 - 10,
                                     y: view.frame.height - 80 - 10 - view.safeAreaInsets.bottom,
                                     width: 80,
                                     height: 80)
        tableView.frame = view.bounds
    }
    @objc private func didTapCreate() {
        let vc = CreateNewPostViewController()
        vc.title = " Tạo bài viết"
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    private var posts: [BlogPost] = []
    
    private func fetchAllPosts() {
        print("Đang tải bài viết cho HomeVC")
        DatabaseManager.shared.getAllPosts { [weak self] posts in
            self?.posts = posts
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
        //Khi nào có IAP
//        guard IAPManager.shared.canViewPost else {
//            let vc = PayWallViewController()
//            present(vc, animated: true, completion: nil)
//            return
//        }
        //Phản hồi xúc giác
        HapticsManager.shared.vibrateForSelection()
        
        let vc = ViewPostViewController(post: posts[indexPath.row])
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = posts[indexPath.row].title
        navigationController?.pushViewController(vc, animated: true)
    }

}

