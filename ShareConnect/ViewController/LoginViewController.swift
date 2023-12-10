//
//  LoginViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/16.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegistrationViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
            } else {
                if let user = Auth.auth().currentUser {
                    print("User is already registered with UID: \(user.uid)")
                    if let buyerID = Auth.auth().currentUser?.uid {
//                        Messaging.messaging().subscribe(toTopic: buyerID)
                    }

                }
            }
        }
    }
}
