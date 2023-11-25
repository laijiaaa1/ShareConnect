//
//  ClassViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/23.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class ClassViewController: UIViewController {
    
    let classProductButton = UIButton()
    let classPlaceButton = UIButton()
    var currentButtonType: ProductType = .request
    var allRequests: [Product] = []
    var allSupplies: [Product] = []
    var classification = ["place", "product"]
    var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "CLASS"
        navigationController?.navigationBar.isHidden = false
        view.backgroundColor = CustomColors.B1
        view.addSubview(classPlaceButton)
        view.addSubview(classProductButton)
        classPlaceButton.translatesAutoresizingMaskIntoConstraints = false
        classProductButton.translatesAutoresizingMaskIntoConstraints = false
        classPlaceButton.backgroundColor = .black
        classProductButton.backgroundColor = .black
        classPlaceButton.addTarget(self, action: #selector(classPlaceButtonAction), for: .touchUpInside)
        classProductButton.addTarget(self, action: #selector(classProductButtonAction), for: .touchUpInside)
        classPlaceButton.setImage(UIImage(named: "place"), for: .normal)
        classPlaceButton.titleLabel?.text = "PLACE"
        classProductButton.setImage(UIImage(named: "product"), for: .normal)
        classProductButton.titleLabel?.text = "PRODUCT"
        classPlaceButton.setTitleColor(.white, for: .normal)
        classProductButton.setTitleColor(.white, for: .normal)
        classPlaceButton.layer.cornerRadius = 15
        classProductButton.layer.cornerRadius = 15
        NSLayoutConstraint.activate([
            classPlaceButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            classPlaceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
            classPlaceButton.widthAnchor.constraint(equalToConstant: 200),
            classPlaceButton.heightAnchor.constraint(equalToConstant: 100),
            classProductButton.topAnchor.constraint(equalTo: classPlaceButton.bottomAnchor, constant: 20),
            classProductButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
            classProductButton.widthAnchor.constraint(equalToConstant: 200),
            classProductButton.heightAnchor.constraint(equalToConstant: 100),
        ])
    }
    
    @objc func classPlaceButtonAction() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "SearchViewController") as! SearchViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func classProductButtonAction() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "SearchViewController") as! SearchViewController
        navigationController?.pushViewController(vc, animated: true)
    }
}
