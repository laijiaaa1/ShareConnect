//
//  SearchPage_ClassCollectionViewCell.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/6.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import MJRefresh
import Kingfisher

class ClassCollectionViewCell: UICollectionViewCell {
    let buttonsStackView = UIStackView()
    let textLabel = UILabel()
    let productClassification = ["Camping", "Tableware", "Activity", "Party", "Sports", "Arts", "Others"]
    var allRequests: [Product] = []
    var allSupplies: [Product] = []
    var currentButtonType: ProductType? {
        didSet {
            updateUI()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        updateUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupUI() {
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.axis = .horizontal
        buttonsStackView.alignment = .center
        buttonsStackView.distribution = .fillProportionally
        contentView.addSubview(buttonsStackView)
        NSLayoutConstraint.activate([
            buttonsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
        ])
    }
    func updateUI() {
        for subview in buttonsStackView.arrangedSubviews {
            buttonsStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        for classification in productClassification {
            let button = UIButton()
            button.setTitle(classification, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(classificationButtonTapped(_:)), for: .touchUpInside)
            buttonsStackView.addArrangedSubview(button)
        }
    }
    weak var delegate: ClassCollectionViewCellDelegate?
    @objc func classificationButtonTapped(_ sender: UIButton) {
        if let classificationText = sender.currentTitle {
            print("Tapped Classification: \(classificationText)")
            if let delegate = delegate, let currentButtonType = currentButtonType {
                if currentButtonType == .request {
                    delegate.didSelectClassification(classificationText, forType: currentButtonType)
                } else if currentButtonType == .supply {
                    delegate.didSelectClassification(classificationText, forType: currentButtonType)
                }
            }
        }
    }
}
