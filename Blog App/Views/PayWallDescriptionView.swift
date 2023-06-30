//
//  PayWallDescriptionView.swift
//  Blog App
//
//  Created by Luyện Hà Luyện on 19/06/2023.
//

import UIKit

class PayWallDescriptionView: UIView {

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.numberOfLines = 0
        label.text = "Tham gia thảo luận không giới hạn với hàng ngàn bài đăng"
        return label
    }()
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 1
        label.text = "100.000Vnđ / tháng"
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubview(priceLabel)
        addSubview(descriptionLabel)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        descriptionLabel.frame = CGRect(x: 20, y: 0,
                                        width: width - 40, height: height / 2)
        priceLabel.frame = CGRect(x: 20, y: height / 2,
                                        width: width - 40, height: height / 2)
    }
}
