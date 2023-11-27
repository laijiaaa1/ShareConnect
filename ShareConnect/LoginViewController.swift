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
        view.backgroundColor = CustomColors.B1
    }
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
            } else {
                guard let uid = Auth.auth().currentUser?.uid else {
                    return
                }
                self.db.collection("users").document(uid).setData([
                    "email": email,
                ]) { error in
                    if let error = error {
                        print("Error adding user to Firestore: \(error.localizedDescription)")
                    } else {
                        print("User added to Firestore successfully")
                        if let buyerID = Auth.auth().currentUser?.uid {
                            Messaging.messaging().subscribe(toTopic: buyerID)
                        }

                    }
                }
            }
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomePageViewController")
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
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "HomePageViewController")
                    self.navigationController?.pushViewController(vc, animated: true)
                    if let buyerID = Auth.auth().currentUser?.uid {
                        Messaging.messaging().subscribe(toTopic: buyerID)
                    }

                }
            }
        }
    }
}
