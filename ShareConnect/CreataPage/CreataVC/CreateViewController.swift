//
//  CreateViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/16.
//

import UIKit

class CreateViewController: UIViewController {
    let greenBackColor = UIColor(red: 183/255, green: 234/255, blue: 24/255, alpha: 1.0)
    let myRequestView = UIImageView()
    let myRequestLabel = UILabel()
    let myRequestButton = UIButton()
    let mySupplyView = UIImageView()
    let mySupplyLabel = UILabel()
    let mySupplyButton = UIButton()
    let createGroupView = UIImageView()
    let createGroupLabel = UILabel()
    let createGroupButton = UIButton()
    let backPicture = UIImageView()
    override func viewDidLoad() {
        view.backgroundColor = .black
        backPicture.image = UIImage(named: "1")
        backPicture.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(backPicture)
        super.viewDidLoad()
        navigationItem.title = "SHARECONNECT"
        myRequestView.layer.cornerRadius = 50
        myRequestView.contentMode = .scaleAspectFill
        myRequestView.layer.masksToBounds = true
        myRequestView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(myRequestView)
        mySupplyView.layer.cornerRadius = 50
        mySupplyView.contentMode = .scaleAspectFill
        mySupplyView.layer.masksToBounds = true
        mySupplyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mySupplyView)
        createGroupView.layer.cornerRadius = 50
        createGroupView.contentMode = .scaleAspectFill
        createGroupView.layer.masksToBounds = true
        createGroupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createGroupView)
        myRequestButton.startAnimatingPressActions()
        myRequestButton.backgroundColor = .clear
        myRequestButton.translatesAutoresizingMaskIntoConstraints = false
        mySupplyButton.startAnimatingPressActions()
        mySupplyButton.backgroundColor = .clear
        mySupplyButton.translatesAutoresizingMaskIntoConstraints = false
        createGroupButton.translatesAutoresizingMaskIntoConstraints = false
        createGroupButton.startAnimatingPressActions()
        createGroupButton.backgroundColor = .clear
        createGroupButton.addTarget(self, action: #selector(createGroupButtonTapped), for: .touchUpInside)
        myRequestButton.addTarget(self, action: #selector(myRequestButtonTapped), for: .touchUpInside)
        mySupplyButton.addTarget(self, action: #selector(mySupplyButtonTapped), for: .touchUpInside)
        view.addSubview(myRequestButton)
        view.addSubview(mySupplyButton)
        view.addSubview(createGroupButton)
        NSLayoutConstraint.activate([
            myRequestView.topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
            myRequestView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            myRequestView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            myRequestView.heightAnchor.constraint(equalToConstant: 150),
            myRequestButton.centerXAnchor.constraint(equalTo: myRequestView.centerXAnchor),
            myRequestButton.topAnchor.constraint(equalTo: myRequestView.topAnchor, constant: 30),
            myRequestButton.widthAnchor.constraint(equalTo: myRequestView.widthAnchor),
            myRequestButton.heightAnchor.constraint(equalToConstant: 120),
            mySupplyView.topAnchor.constraint(equalTo: myRequestView.bottomAnchor, constant: 60),
            mySupplyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            mySupplyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            mySupplyView.heightAnchor.constraint(equalToConstant: 150),
            mySupplyButton.centerXAnchor.constraint(equalTo: mySupplyView.centerXAnchor),
            mySupplyButton.topAnchor.constraint(equalTo: mySupplyView.topAnchor, constant: 30),
            mySupplyButton.widthAnchor.constraint(equalTo: mySupplyView.widthAnchor),
            mySupplyButton.heightAnchor.constraint(equalToConstant: 120),
            createGroupView.topAnchor.constraint(equalTo: mySupplyView.bottomAnchor, constant: 60),
            createGroupView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            createGroupView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            createGroupView.heightAnchor.constraint(equalToConstant: 150),
            createGroupButton.centerXAnchor.constraint(equalTo: createGroupView.centerXAnchor),
            createGroupButton.topAnchor.constraint(equalTo: createGroupView.topAnchor, constant: 30),
            createGroupButton.widthAnchor.constraint(equalTo: createGroupView.widthAnchor),
            createGroupButton.heightAnchor.constraint(equalToConstant: 120)
        ])
        animationStart()
    }
    func animationStart() {
        // 圖片上下浮動動畫
        let animatedBackgroundImageView = UIImageView(image: UIImage(named: "Create_Green"))
        animatedBackgroundImageView.frame = CGRect(x: 250, y: -20, width: view.bounds.width / 3, height: view.bounds.height / 3)
        animatedBackgroundImageView.contentMode = .scaleAspectFit
        backPicture.insertSubview(animatedBackgroundImageView, at: 0)
        // 啟動上下浮動
        UIView.animate(withDuration: 2.0, delay: 0.0, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
            // 設置動畫的最終位置
            animatedBackgroundImageView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height / 20)
        }, completion: nil)
        let animatedOrange = UIImageView(image: UIImage(named: "Create_Orange"))
        animatedOrange.frame = CGRect(x: 20, y: 190, width: view.bounds.width / 3, height: view.bounds.height / 3)
        animatedOrange.contentMode = .scaleAspectFit
        backPicture.insertSubview(animatedOrange, at: 0)
        UIView.animate(withDuration: 2.0, delay: 0.0, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
            animatedOrange.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height / 20)
        }, completion: nil)
        let animatedWhite = UIImageView(image: UIImage(named: "Create_White"))
        animatedWhite.frame = CGRect(x: 0, y: 400, width: view.bounds.width/1.1, height: view.bounds.height/1.1)
        animatedWhite.contentMode = .scaleAspectFit
        backPicture.insertSubview(animatedWhite, at: 0)
        // CABasicAnimation 從左到右平移動畫
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.fromValue = -view.bounds.width / 2
        animation.toValue = view.bounds.width * 1.5
        animation.duration = 10.0
        animation.repeatCount = Float.infinity // 無限循環
        // 將動畫加上視圖層
        animatedWhite.layer.add(animation, forKey: "positionAnimation")
    }
    @objc func myRequestButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createRequestViewController = storyboard.instantiateViewController(withIdentifier: "CreateRequestViewController") as! CreateRequestViewController
        navigationController?.pushViewController(createRequestViewController, animated: true)
    }
    @objc func mySupplyButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createSupplyViewController = storyboard.instantiateViewController(withIdentifier: "CreateSupplyViewController") as! CreateSupplyViewController
        navigationController?.pushViewController(createSupplyViewController, animated: true)
    }
    @objc func createGroupButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createGroupViewController = storyboard.instantiateViewController(withIdentifier: "CreateGroupViewController") as! CreateGroupViewController
        navigationController?.pushViewController(createGroupViewController, animated: true)
    }
}
