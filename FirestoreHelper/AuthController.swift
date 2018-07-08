//
//  AuthController.swift
//  FirestoreHelper
//
//  Created by Yaroslav Erohin on 08.07.2018.
//  Copyright © 2018 Ysoftware. All rights reserved.
//

#if canImport(AuthController)

import AuthController
import FirebaseAuth
import FirebaseFirestore
import CoreLocation

class FirestoreUserObserver: UserObserver {

	let listener:ListenerRegistration

	init(_ listener:ListenerRegistration) {
		self.listener = listener
	}

	func remove() {
		listener.remove()
	}
}

class FirestoreAuthService<U:AuthControllerUser>: AuthNetworking<U> where U:Codable {

	var user:U?

	override func getUser() -> U? {
		return user
	}

	override func updateLastSeen() {
		guard let userId = user?.id else { return }
		Firestore.updateLastSeen(userId: userId)
	}

	override func updateLocation(_ location: CLLocation) {
		guard let userId = user?.id else { return }
		Firestore.updateLocation(userId: userId, location)
	}

	override func observeUser(id: String, _ block: @escaping (U?) -> Void) -> UserObserver {
		let userRef = Firestore.ref(.users).document(id)
		let handle = Firestore.observe(at: userRef) { (user:U?) in
			self.user = user
			block(user)
		}
		return FirestoreUserObserver(handle)
	}

	override func updateToken() {
		guard let userId = user?.id else { return }
		Firestore.updateToken(userId: userId)
	}

	override func updateVersionCode() {
		guard let userId = user?.id else { return }
		Firestore.updateVersionCode(userId: userId)
	}

	override func removeToken() {
		guard let userId = user?.id else { return }
		Firestore.removeToken(userId: userId)
	}

	override func signOut() {
		Firestore.signOut()
	}

	override func onAuthStateChanged(_ block: @escaping () -> Void) {
		Auth.auth().addStateDidChangeListener { _, _ in
			block()
		}
	}
}
#endif

