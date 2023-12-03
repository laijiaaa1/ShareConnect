//
//  SettingProfileViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/3.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class SettingProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let logoutButton = UIButton(type: .system)
        logoutButton.setTitle("登出", for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        let deleteAccountButton = UIButton(type: .system)
        deleteAccountButton.setTitle("刪除帳號", for: .normal)
        deleteAccountButton.addTarget(self, action: #selector(deleteAccountButtonTapped), for: .touchUpInside)
        view.addSubview(logoutButton)
        view.addSubview(deleteAccountButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        deleteAccountButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            deleteAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteAccountButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
        ])
    }
    @objc func logoutButtonTapped() {
        showConfirmationAlert(title: "確認登出", message: "確定要登出嗎？", confirmAction: {
            do {
                try Auth.auth().signOut()
                print("已登出")
                self.navigateToLoginScreen()
            } catch let signOutError as NSError {
                print("登出錯誤: \(signOutError.localizedDescription)")
            }
        })
    }
    @objc func deleteAccountButtonTapped() {
        showConfirmationAlert(title: "確認刪除帳號", message: "確定要刪除帳號嗎？", confirmAction: {
            let user = Auth.auth().currentUser
            guard let currentUser = user else {
                print("無法獲取當前用戶")
                return
            }
            let db = Firestore.firestore()
            let userCollection = db.collection("users")
            let userDocument = userCollection.document(currentUser.uid)
            
            userDocument.delete { error in
                if let error = error {
                    print("刪除用戶集合錯誤: \(error.localizedDescription)")
                } else {
                    print("用戶集合已成功刪除")
                    currentUser.delete { error in
                        if let error = error {
                            print("刪除帳號錯誤: \(error.localizedDescription)")
                        } else {
                            print("帳號已成功刪除")
                            self.navigateToLoginScreen()
                        }
                    }
                }
            }
        })
    }

    func navigateToLoginScreen() {
        let rootViewController = UIApplication.shared.windows.first!.rootViewController
        
        if let tabBarController = rootViewController as? UITabBarController {
            if let selectedViewController = tabBarController.selectedViewController as? UINavigationController {
                selectedViewController.popToRootViewController(animated: true)
            }
        } else if let navigationController = rootViewController as? UINavigationController {
            navigationController.popToRootViewController(animated: true)
        }
    }

    func showConfirmationAlert(title: String, message: String, confirmAction: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確定", style: .destructive) { _ in
            confirmAction()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
