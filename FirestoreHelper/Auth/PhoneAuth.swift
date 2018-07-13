//
//  MainVC.swift
//  ProfitProjects
//
//  Created by Eugene on 06.06.17.
//  Copyright © 2017 ProfitProjects. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

/// Класс контроллера логина по мобильному телефону.
open class PhoneAuthVC: UIViewController {

	// MARK: - Outlets

	// ввести номер телефона и запросить код
	@IBOutlet weak var numberView: UIView!
	@IBOutlet weak var numberTextField: UITextField!
	@IBOutlet weak var verifyButton: UIButton!

	// ввести код и войти
	@IBOutlet weak var verificationView: UIView!
	@IBOutlet weak var codeField: UITextField!
	@IBOutlet weak var signUpButton: UIButton!
	@IBOutlet weak var backButton: UIButton!

	// MARK: - Actions

	@IBAction final func verifySend(_ sender: Any) {
		verifyPhoneNumber()
	}

	@IBAction final func signIn(_ sender: Any) {
		verifyCode()
	}

	@IBAction func backTapped(_ sender: Any) {
		isShowingVerification = false
	}

	@IBAction func openPrivacy(_ sender: Any) {
		assertionFailure("реализуйте override EmailAuthVC.openPrivacy")
	}

	@IBAction open func hideLogin() {
		// реализуйте override EmailAuthVC.hideLogin
	}

	// MARK: - Properties

	private var verificationId:String?

	private var isShowingVerification = false {
		didSet {
			verificationView.isHidden = !isShowingVerification
			numberView.isHidden = isShowingVerification
			backButton.isHidden = !isShowingVerification

			if isShowingVerification {
				codeField.becomeFirstResponder()
				codeField.text = ""
			}
			else {
				numberTextField.becomeFirstResponder()
			}
		}
	}

	// MARK: - Methods

	override open func viewDidLoad() {
		super.viewDidLoad()
		isShowingVerification = false
	}

	private func verifyPhoneNumber() {
		let phoneNumber = numberTextField.text!
			.trimmingCharacters(in: .whitespacesAndNewlines)

		guard phoneNumber.count > 7 else { // почему 7?
			return
		}

		PhoneAuthProvider.provider()
			.verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationId, error in
				DispatchQueue.main.async {
					if let error = error {
						self.call(message: error.localizedDescription)
					}
					else {
						self.isShowingVerification = true
						self.verificationId = verificationId
					}
				}
		}
	}

	private func verifyCode() {
		guard let verificationId = verificationId else { return }

		let code = codeField.text!
			.trimmingCharacters(in: .whitespacesAndNewlines)

		let credential = PhoneAuthProvider.provider()
			.credential(withVerificationID: verificationId,
						verificationCode: code)

		FirestoreHelper.signIn(credentials: credential, completion: { error in
			if let error = error {
				self.call(message: error.localizedDescription)
			}
			else {
				self.hideLogin()
			}
		})
	}
}
