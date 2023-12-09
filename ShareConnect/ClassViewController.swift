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
    let alphaView = UIView()
    let placeLabel = UILabel()
    let productLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "CLASS"
        navigationController?.navigationBar.isHidden = false
        view.backgroundColor = .black
        view.addSubview(classPlaceButton)
        view.addSubview(classProductButton)
        view.addSubview(placeLabel)
        view.addSubview(productLabel)
        placeLabel.frame.size = CGSize(width: 200, height: 50)
        productLabel.frame.size = CGSize(width: 200, height: 50)
        placeLabel.text = "PLACE"
        productLabel.text = "PRODUCT"
        placeLabel.textColor = .white
        productLabel.textColor = .white
        placeLabel.font = UIFont.systemFont(ofSize: 30)
        productLabel.font = UIFont.systemFont(ofSize: 30)
        placeLabel.textAlignment = .center
        productLabel.textAlignment = .center
        alphaView.translatesAutoresizingMaskIntoConstraints = false
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
        classPlaceButton.layer.cornerRadius = 125
        classProductButton.layer.cornerRadius = 125
        classPlaceButton.layer.masksToBounds = true
        classProductButton.layer.masksToBounds = true
        NSLayoutConstraint.activate([
            classPlaceButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            classPlaceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            classPlaceButton.widthAnchor.constraint(equalTo: view.widthAnchor),
            classPlaceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 80),
            classPlaceButton.heightAnchor.constraint(equalToConstant: 250),
            classProductButton.topAnchor.constraint(equalTo: classPlaceButton.bottomAnchor, constant: 50),
            classProductButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            classProductButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -80),
            classProductButton.widthAnchor.constraint(equalTo: view.widthAnchor),
            classProductButton.heightAnchor.constraint(equalToConstant: 250)
        ])
        placeLabel.translatesAutoresizingMaskIntoConstraints = false
        productLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            placeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
            placeLabel.widthAnchor.constraint(equalTo: view.widthAnchor),
            placeLabel.heightAnchor.constraint(equalToConstant: 350),
            productLabel.topAnchor.constraint(equalTo: placeLabel.bottomAnchor),
            productLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            productLabel.widthAnchor.constraint(equalTo: view.widthAnchor),
            productLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    @objc func classPlaceButtonAction() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "SearchViewController") as! SearchViewController
        vc.usification = "place"
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc func classProductButtonAction() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "SearchViewController") as! SearchViewController
        vc.usification = "product"
        navigationController?.pushViewController(vc, animated: true)
    }
}
