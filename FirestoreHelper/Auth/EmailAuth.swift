//
//  EmailAuthVC.swift
//  iOSBeer
//
//  Created by ysoftware on 30.11.2017.
//  Copyright © 2017 Eugene. All rights reserved.
//

import UIKit
import FirebaseAuth

/// Класс контроллера логина по электронной почте.
open class EmailAuthVC: UIViewController {

	// MARK: - Properties

	open var minimumPasswordLength = 6
	open var shortPasswordMessage = "Слишком короткий пароль"
	open var resetPasswordMesage = "Инструкции по восстановлению пароля отправлены на вашу почту"

	// MARK: - Outlets

	@IBOutlet weak var emailField:UITextField!
	@IBOutlet weak var passwordField:UITextField!
	@IBOutlet weak var signInButton:UIButton!

	// MARK: - Actions

	@IBAction func signIn(_ sender: Any) {
		let email = emailField.text!
		let password = passwordField.text!

		guard checkPasswordLength(password) else { return call(message: shortPasswordMessage) }

		FirestoreHelper.signIn(email: email, password: password) { error in
			if let error = error {
				self.call(message: error.localizedDescription)
			}
			else {
				self.hideLogin()
			}
		}
	}

	@IBAction func signUp(_ sender: Any) {
		let email = emailField.text!
		let password = passwordField.text!

		guard checkPasswordLength(password) else { return call(message: shortPasswordMessage) }

		FirestoreHelper.signUp(email: email, password: password, signInIfUserExists:false) { error in
			if let error = error {
				self.call(message: error.localizedDescription)
			}
			else {
				self.hideLogin()
			}
		}
	}

	@IBAction func resetPassword(_ sender:Any) { // TO-DO: Никогда не проверял как это работает
		let email = emailField.text!
		FirestoreHelper.resetPassword(email: email) { error in
			if let error = error {
				self.call(message: error.localizedDescription)
			}
			else {
				self.call(message: self.resetPasswordMesage)
			}
		}
	}

	@IBAction func openPrivacy(_ sender: Any) {
		assertionFailure("реализуйте override EmailAuthVC.openPrivacy")
	}

	@IBAction open func hideLogin() {
		// реализуйте override EmailAuthVC.hideLogin
	}

	// MARK: - Private

	private func checkPasswordLength(_ password:String) -> Bool {
		return password.count >= minimumPasswordLength
	}
}
