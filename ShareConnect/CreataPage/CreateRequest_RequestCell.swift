//
//  CreateRequestViewController_RequestCell.swift
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
import DatePicker

class RequestCell: UITableViewCell {
    let requestLabel = UILabel()
    let textField = UITextField()
    let pickerView = UIPickerView()
    var pickerData: [String] = [String]()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    func setupUI() {
        requestLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(requestLabel)
        NSLayoutConstraint.activate([
            requestLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            requestLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            requestLabel.widthAnchor.constraint(equalToConstant: 100),
            requestLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        // 配置 textField
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isUserInteractionEnabled = true
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 10
        textField.minimumFontSize = 10
        textField.adjustsFontSizeToFitWidth = true
        contentView.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: requestLabel.topAnchor),
            textField.leadingAnchor.constraint(equalTo: requestLabel.trailingAnchor),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            textField.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
