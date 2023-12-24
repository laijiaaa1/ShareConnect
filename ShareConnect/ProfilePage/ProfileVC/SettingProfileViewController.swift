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
    let viewModel = SettingProfileViewModel()
    let outImage = UIImageView()
    let logoutButton = UIButton(type: .system)
    let deleteAccountButton = UIButton(type: .system)
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .black
        view.backgroundColor = CustomColors.B1
        outImage.image = UIImage(named: "icons8-logout-90")
        logoutButton.setTitle("登出", for: .normal)
        logoutButton.tintColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1.0)
        deleteAccountButton.setTitle("刪除帳號", for: .normal)
        deleteAccountButton.tintColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1.0)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        deleteAccountButton.addTarget(self, action: #selector(deleteAccountButtonTapped), for: .touchUpInside)
        view.addSubview(outImage)
        view.addSubview(logoutButton)
        view.addSubview(deleteAccountButton)
        outImage.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        deleteAccountButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            outImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            outImage.widthAnchor.constraint(equalToConstant: 40),
            outImage.heightAnchor.constraint(equalToConstant: 40),
            outImage.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -30),
            deleteAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteAccountButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50)
        ])
    }
    @objc func logoutButtonTapped() {
        showConfirmationAlert(title: "確認登出", message: "確定要登出嗎？") {
            self.viewModel.logout { result in
                switch result {
                case .success:
                    print("已登出")
                    self.navigateToLoginScreen()
                case .failure(let error):
                    print("登出錯誤: \(error.localizedDescription)")
                }
            }
        }
    }
    @objc func deleteAccountButtonTapped() {
        showConfirmationAlert(title: "確認刪除帳號", message: "確定要刪除帳號嗎？") {
            self.viewModel.deleteAccount { result in
                switch result {
                case .success:
                    print("帳號已成功刪除")
                    self.navigateToLoginScreen()
                case .failure(let error):
                    print("刪除帳號錯誤: \(error.localizedDescription)")
                }
            }
        }
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
