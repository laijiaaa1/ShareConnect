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
        view.backgroundColor = CustomColors.B1
//        view.addSubview(alphaView)
        view.addSubview(classPlaceButton)
        view.addSubview(classProductButton)
       
        view.addSubview(placeLabel)
        view.addSubview(productLabel)
        
        
//        alphaView.backgroundColor = .black
//        alphaView.alpha = 0.5
        placeLabel.frame.size = CGSize(width: 100, height: 50)
        productLabel.frame.size = CGSize(width: 100, height: 50)
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
        classPlaceButton.layer.cornerRadius = 150
        classProductButton.layer.cornerRadius = 150
        classPlaceButton.layer.masksToBounds = true
        classProductButton.layer.masksToBounds = true
        NSLayoutConstraint.activate([
//            alphaView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            alphaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            alphaView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            alphaView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            classPlaceButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            classPlaceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            classPlaceButton.widthAnchor.constraint(equalTo: view.widthAnchor),
            classPlaceButton.heightAnchor.constraint(equalToConstant: 280),
            classProductButton.topAnchor.constraint(equalTo: classPlaceButton.bottomAnchor, constant: 30),
            classProductButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35),
            classProductButton.widthAnchor.constraint(equalTo: view.widthAnchor),
            classProductButton.heightAnchor.constraint(equalToConstant: 300),
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
            productLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
