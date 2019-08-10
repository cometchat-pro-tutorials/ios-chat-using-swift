//
//  SignUpViewController.swift
//  CometChat
//
//  Created by Marin Benčević on 09/08/2019.
//  Copyright © 2019 marinbenc. All rights reserved.
//

import UIKit

final class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailTextFieldBackground: UIView!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        emailTextField.borderStyle = .none
        emailTextField.backgroundColor = .clear
        emailTextFieldBackground.layer.addBottomBorder(width: 2)
        
        signUpButton.layer.cornerRadius = 5
        signUpButton.layer.addShadow(
            color: .buttonShadow,
            offset: CGSize(width: 0, height: 5),
            radius: 15)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        //
    }
    
}
