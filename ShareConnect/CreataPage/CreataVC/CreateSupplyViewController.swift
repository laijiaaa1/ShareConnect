//
//  CreateSupplyViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/16.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import ProgressHUD

class CreateSupplyViewController: CreateRequestViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Create Supply"
    }
    @objc override func doneButtonTappedForRequest() {
        doneButtonTapped(itemType: .supply)
    }
}
