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
        logoutButton.setTitle("Log Out", for: .normal)
        logoutButton.tintColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1.0)
        deleteAccountButton.setTitle("Delete Account & All Data", for: .normal)
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
        showConfirmationAlert(title: "Confirm Logout", message: "Are You Sure To Logout？") {
            self.viewModel.logout { result in
                switch result {
                case .success:
                    print("Logout Successfully")
                    self.navigateToLoginScreen()
                case .failure(let error):
                    print("Logout Fail: \(error.localizedDescription)")
                }
            }
        }
    }
    @objc func deleteAccountButtonTapped() {
        showConfirmationAlert(title: "Confirm Delete Account", message: "Are You Sure To Delete Account？") {
            self.viewModel.deleteAccount { result in
                switch result {
                case .success:
                    print("Delete Successfully")
                    self.navigateToLoginScreen()
                case .failure(let error):
                    print("Delete Fail: \(error.localizedDescription)")
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
        let confirmAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            confirmAction()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
