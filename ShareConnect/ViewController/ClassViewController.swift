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
    let shimmerView: UIView = {
           let view = UIView()
           view.backgroundColor = .white
           view.layer.cornerRadius = 125
           view.layer.masksToBounds = true
           view.translatesAutoresizingMaskIntoConstraints = false
           return view
       }()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        view.backgroundColor = .black
        let backPicture = UIImageView()
        backPicture.image = UIImage(named: "2")
        backPicture.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(backPicture)
        view.addSubview(classPlaceButton)
        view.addSubview(classProductButton)
        view.addSubview(placeLabel)
        view.addSubview(productLabel)
        placeLabel.frame.size = CGSize(width: 200, height: 50)
        productLabel.frame.size = CGSize(width: 200, height: 50)
        placeLabel.textColor = .white
        productLabel.textColor = .white
        placeLabel.font = UIFont.systemFont(ofSize: 30)
        productLabel.font = UIFont.systemFont(ofSize: 30)
        placeLabel.textAlignment = .center
        productLabel.textAlignment = .center
        alphaView.translatesAutoresizingMaskIntoConstraints = false
        classPlaceButton.translatesAutoresizingMaskIntoConstraints = false
        classProductButton.translatesAutoresizingMaskIntoConstraints = false
        classPlaceButton.backgroundColor = .clear
        classProductButton.backgroundColor = .clear
        classPlaceButton.addTarget(self, action: #selector(classPlaceButtonAction), for: .touchUpInside)
        classProductButton.addTarget(self, action: #selector(classProductButtonAction), for: .touchUpInside)
        classPlaceButton.setTitleColor(.white, for: .normal)
        classProductButton.setTitleColor(.white, for: .normal)
        classPlaceButton.layer.cornerRadius = 125
        classProductButton.layer.cornerRadius = 125
        classPlaceButton.layer.masksToBounds = true
        classProductButton.layer.masksToBounds = true
        NSLayoutConstraint.activate([
            classPlaceButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            classPlaceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            classPlaceButton.widthAnchor.constraint(equalTo: view.widthAnchor),
            classPlaceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 80),
            classPlaceButton.heightAnchor.constraint(equalToConstant: 250),
            classProductButton.topAnchor.constraint(equalTo: classPlaceButton.bottomAnchor, constant: 100),
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
        // 将 G2 图片添加到视图层次结构中
        let g2ImageView = Class_Space(frame: CGRect(x: 300, y: 120, width: 400, height: 250))
             g2ImageView.translatesAutoresizingMaskIntoConstraints = false
             view.addSubview(g2ImageView)

             // 添加约束
             NSLayoutConstraint.activate([
                 g2ImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 110),
                 g2ImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -160),
                 g2ImageView.widthAnchor.constraint(equalToConstant: 400),
                 g2ImageView.heightAnchor.constraint(equalToConstant: 400)
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
