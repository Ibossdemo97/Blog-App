//
//  SignInHeaderView.swift
//  Blog App
//
//  Created by Luyện Hà Luyện on 20/06/2023.
//

import UIKit

class SignInHeaderView: UIView {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "blog icon"))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemPink
        return imageView
    }()
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Khám phá hàng triệu bài viết"
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubview(imageView)
        addSubview(label)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size: CGFloat = width/4
        imageView.frame = CGRect(x: (width - size) / 2, y: 10, width: size, height: size)
        label.frame = CGRect(x: 20, y: imageView.bottom + 10, width: width - 40, height: height - size - 30)
    }
}
