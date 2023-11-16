//
//  CreateViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/16.
//

import UIKit

class CreateViewController: UIViewController {

    let greenBackColor = UIColor(red: 183/255, green: 234/255, blue: 24/255, alpha: 1.0)
    let myRequestView = UIView()
    let myRequestLabel = UILabel()
    let myRequestButton = UIButton()
    
    let mySupplyView = UIView()
    let mySupplyLabel = UILabel()
    let mySupplyButton = UIButton()
    
    let createGroupView = UIView()
    let createGroupLabel = UILabel()
    let createGroupButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myRequestView.layer.cornerRadius = 50
        myRequestView.backgroundColor = .yellow
        myRequestView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(myRequestView)
        
        myRequestButton.setTitle("My request", for: .normal)
        myRequestButton.backgroundColor = greenBackColor
        myRequestButton.setTitleColor(.black, for: .normal)
        myRequestButton.layer.cornerRadius = 25
        myRequestButton.translatesAutoresizingMaskIntoConstraints = false
        
        myRequestButton.addTarget(self, action: #selector(myRequestButtonTapped), for: .touchUpInside)
        myRequestView.addSubview(myRequestButton)
        
        NSLayoutConstraint.activate([
            myRequestView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            myRequestView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            myRequestView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            myRequestView.heightAnchor.constraint(equalToConstant: 100),
            myRequestButton.centerXAnchor.constraint(equalTo: myRequestView.centerXAnchor),
            myRequestButton.topAnchor.constraint(equalTo: myRequestView.topAnchor, constant: 70),
            myRequestButton.widthAnchor.constraint(equalTo: myRequestView.widthAnchor, multiplier: 0.8),
            myRequestButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        

    }
    
    
    @objc func myRequestButtonTapped() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createRequestViewController = storyboard.instantiateViewController(withIdentifier: "CreateRequestViewController") as! CreateRequestViewController
        navigationController?.pushViewController(createRequestViewController, animated: true)
    }
}
