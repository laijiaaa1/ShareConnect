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
    let addBtn = UIButton()
    let textField = UITextField()
    var isExpanded: Bool = false {
        didSet {
            updateCellHeight()
        }
    }
    let pickerView = UIPickerView()
    var pickerData: [String] = [String]()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    func setupUI() {
        requestLabel.translatesAutoresizingMaskIntoConstraints = false
        addBtn.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isHidden = true
        textField.isUserInteractionEnabled = true
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 10
        textField.minimumFontSize = 10
        textField.adjustsFontSizeToFitWidth = true
        contentView.addSubview(addBtn)
        contentView.addSubview(requestLabel)
        contentView.addSubview(textField)
        NSLayoutConstraint.activate([
            requestLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            requestLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            requestLabel.widthAnchor.constraint(equalToConstant: 250),
            requestLabel.heightAnchor.constraint(equalToConstant: 20),
            addBtn.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            addBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            addBtn.widthAnchor.constraint(equalToConstant: 20),
            addBtn.heightAnchor.constraint(equalToConstant: 20),
            textField.topAnchor.constraint(equalTo: requestLabel.bottomAnchor, constant: 10),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            textField.heightAnchor.constraint(equalToConstant: 60)
        ])
        addBtn.addTarget(self, action: #selector(addBtnTapped), for: .touchUpInside)
    }
    @objc func addBtnTapped() {
        isExpanded = !isExpanded
    }
    private func updateCellHeight() {
        let newHeight: CGFloat = isExpanded ? 120 : 50
        frame.size.height = newHeight
        textField.isHidden = !isExpanded
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
