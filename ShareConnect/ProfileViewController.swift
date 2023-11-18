//
//  ProfileViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/18.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Placeholder: Replace with logic to determine the number of groups based on user data
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupCell
        // Placeholder: Customize the cell based on user data
        cell.nameLabel.text = "Group \(indexPath.row + 1)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Placeholder: Replace with logic to determine the number of collection items based on user data
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
        // Placeholder: Customize the cell based on user data
        cell.backgroundColor = .lightGray
        cell.nameLabel.text = "Item \(indexPath.item + 1)"
        return cell
    }
    
    let headerImage = UIImageView()
    let nameLabel = UILabel()
    let stackView = UIStackView()
    let lineView = UIView()
    
    let groupButton = UIButton()
    let collectionButton = UIButton()
    let requestButton = UIButton()
    let supplyButton = UIButton()
    let settingButton = UIButton()
    let logoutButton = UIButton()
    
    let groupTableView = UITableView()
    let collectionCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let requestTableView = UITableView()
    let supplyTableView = UITableView()
    var selectedButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = CustomColors.B1
        
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Luna"
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        // 4 buttons stack view
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        stackView.addArrangedSubview(groupButton)
        stackView.addArrangedSubview(collectionButton)
        stackView.addArrangedSubview(requestButton)
        stackView.addArrangedSubview(supplyButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 5),
            stackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Setting buttons
        let labels = [groupButton, collectionButton, requestButton, supplyButton]
        labels.forEach { (label) in
            label.backgroundColor = .white
            label.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            label.setTitleColor(.black, for: .normal)
        }
        groupButton.setTitle("Group", for: .normal)
        collectionButton.setTitle("Collection", for: .normal)
        requestButton.setTitle("Request", for: .normal)
        supplyButton.setTitle("Supply", for: .normal)
        
        groupButton.addTarget(self, action: #selector(groupButtonTapped), for: .touchUpInside)
        collectionButton.addTarget(self, action: #selector(collectionButtonTapped), for: .touchUpInside)
        requestButton.addTarget(self, action: #selector(requestButtonTapped), for: .touchUpInside)
        supplyButton.addTarget(self, action: #selector(supplyButtonTapped), for: .touchUpInside)
        
        // Line view
        view.addSubview(lineView)
        lineView.backgroundColor = .black
        lineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            lineView.heightAnchor.constraint(equalToConstant: 1),
            lineView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor)
        ])
        
        // Group Table View
        view.addSubview(groupTableView)
        groupTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            groupTableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            groupTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            groupTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            groupTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
        
        groupTableView.dataSource = self
        groupTableView.delegate = self
        groupTableView.register(GroupCell.self, forCellReuseIdentifier: "GroupCell")
        
        // Collection Collection View
        collectionCollectionView.isHidden = true
        view.addSubview(collectionCollectionView)
        collectionCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionCollectionView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            collectionCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
        
        // Add this configuration for collectionCollectionView
        let layout = UICollectionViewFlowLayout()
        collectionCollectionView.collectionViewLayout = layout
        collectionCollectionView.dataSource = self
        collectionCollectionView.delegate = self
        collectionCollectionView.register(CollectionCell.self, forCellWithReuseIdentifier: "CollectionCell")
    }
    @objc func groupButtonTapped() {
        animateLineViewTransition(to: groupButton)
        animateViewTransition(to: groupTableView)
    }
    
    @objc func collectionButtonTapped() {
        animateLineViewTransition(to: collectionButton)
        animateViewTransition(to: collectionCollectionView)
    }
    
    @objc func requestButtonTapped() {
        animateLineViewTransition(to: requestButton)
        animateViewTransition(to: requestTableView)
    }
    
    @objc func supplyButtonTapped() {
        animateLineViewTransition(to: supplyButton)
        animateViewTransition(to: supplyTableView)
    }
    
    // Function to update lineView position with animation
    private func animateLineViewTransition(to button: UIButton) {
        // Update selectedButton
        selectedButton?.setTitleColor(.black, for: .normal)
        button.setTitleColor(.blue, for: .normal)
        selectedButton = button
        
        // Animate the movement of the lineView
        UIView.animate(withDuration: 0.3) {
            self.lineView.frame.origin.x = button.frame.origin.x
        }
    }
    
    // Function to animate view transition
    private func animateViewTransition(to newView: UIView) {
        UIView.animate(withDuration: 0.3) {
            // Fade out all views
            self.groupTableView.alpha = 0
            self.collectionCollectionView.alpha = 0
            self.requestTableView.alpha = 0
            self.supplyTableView.alpha = 0
        } completion: { _ in
            // Hide all views after animation completion
            self.groupTableView.isHidden = true
            self.collectionCollectionView.isHidden = true
            self.requestTableView.isHidden = true
            self.supplyTableView.isHidden = true
            
            // Show the selected view
            newView.alpha = 1
            newView.isHidden = false
        }
    }
}


class CollectionCell: UICollectionViewCell {

    let imageView = UIImageView()
    let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GroupCell: UITableViewCell {

    let nameLabel = UILabel()
    let descriptionLabel = UILabel()
    let dateLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        nameLabel.numberOfLines = 0
        descriptionLabel.numberOfLines = 0
        dateLabel.numberOfLines = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
