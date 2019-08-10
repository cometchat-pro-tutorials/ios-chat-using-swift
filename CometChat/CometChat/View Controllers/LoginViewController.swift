//
//  LoginViewController.swift
//  CometChat
//
//  Created by Marin Benčević on 09/08/2019.
//  Copyright © 2019 marinbenc. All rights reserved.
//

import UIKit

final class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailTextFieldBackground: UIView!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        emailTextField.borderStyle = .none
        emailTextField.backgroundColor = .clear
        emailTextFieldBackground.layer.addBottomBorder(width: 2)
        
        loginButton.layer.cornerRadius = 5
        loginButton.layer.addShadow(
            color: .buttonShadow,
            offset: CGSize(width: 0, height: 5),
            radius: 15)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        let email = emailTextField.text!
        guard !email.isEmpty else {
            return
        }
        
        ChatService.shared.login(email: email) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.navigationController?.dismiss(animated: true)
                case .failure(let error):
                    print(error)
                    self?.showError(error)
                }
            }
        }
    }
    
    private func showError(_ error: String) {
        let alert = UIAlertController(title: error, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default))
        navigationController?.present(alert, animated: true)
    }

}
