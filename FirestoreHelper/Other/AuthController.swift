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
import Result

public class FirestoreUserObserver: UserObserver {

	let listener:ListenerRegistration

	public init(_ listener:ListenerRegistration) {
		self.listener = listener
	}

	public func remove() {
		listener.remove()
	}
}

public class FirestoreAuthService<U:AuthControllerUser>: AuthNetworking<U> where U:Codable {

	override public func getUserId() -> String? {
		return Auth.auth().currentUser?.uid
	}

	override public func updateLastSeen() {
		guard let userId = getUserId() else { return }
		FirestoreHelper.updateLastSeen(userId: userId)
	}

	override public func updateLocation(_ location: CLLocation) {
		guard let userId = getUserId() else { return }
		FirestoreHelper.updateLocation(userId: userId, location)
	}

	override public func observeUser(id: String, _ block: @escaping (U?) -> Void) -> UserObserver {
		let userRef = FirestoreHelper.ref(usersRef).document(id)
		let handle = FirestoreHelper.observe(at: userRef) { (result:Result<U, FirestoreHelperError>) in
			switch result {
			case .success(let user):
				block(user)
			case .failure(_):
				block(nil)
			}
		}
		return FirestoreUserObserver(handle)
	}

	override public func updateToken() {
		guard let userId = getUserId() else { return }
		FirestoreHelper.updateToken(userId: userId)
	}

	override public func updateVersionCode() {
		guard let userId = getUserId() else { return }
		FirestoreHelper.updateVersionCode(userId: userId)
	}

	override public func removeToken() {
		guard let userId = getUserId() else { return }
		FirestoreHelper.removeToken(userId: userId)
	}

	override public func signOut() {
		FirestoreHelper.signOut()
	}

	override public func onAuthStateChanged(_ block: @escaping () -> Void) {
		Auth.auth().addStateDidChangeListener { _, _ in
			block()
		}
	}
}
#endif

