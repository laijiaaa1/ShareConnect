//
//  LoginViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/16.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = CustomColors.B1
        // Do any additional setup after loading the view.
    }
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            // Handle invalid input
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                // Handle registration error
            } else {
                //                    // User registered successfully
                //                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                //                            let vc = storyboard.instantiateViewController(withIdentifier: "HomePageViewController")
                //                            self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //        let vc = storyboard.instantiateViewController(withIdentifier: "HomePageViewController")
        //        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            // Handle invalid input
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                // Handle login error
            } else {
                // User signed in successfully
                //                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                //                            let vc = storyboard.instantiateViewController(withIdentifier: "HomePageViewController")
                //                            self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
