//
//  Auth.swift
//  FirestoreHelper
//
//  Created by Yaroslav Erohin on 30.11.2017.
//  Copyright © 2017 Ysoftware. All rights reserved.
//

import FirebaseFirestore
import FirebaseInstanceID
import FirebaseAuth
import CoreLocation

public let usersRef = "users"

extension FirestoreHelper {

	// MARK: - Auth 

	/// Совершить аутенфикацию по номеру телефона.
	///
	/// - Parameters:
	/// 	- credentials: Данные полученные при подтверждении кода из смс.
	/// 	- completion: Блок, вызываемый при окончании запроса.
	public static func signIn(credentials: PhoneAuthCredential,
							  completion: @escaping Completion.Error) {
		Auth.auth().signInAndRetrieveData(with: credentials) { result, error in
			if let error = error {
				completion(error)
			}
			else if let user = result?.user {
				let userRef = ref(usersRef).document(user.uid)
				userRef.setData([
					Constants.User.id:user.uid as Any,
					Constants.User.phoneNumber:user.phoneNumber as Any
					], merge: true)
				completion(nil)
			}
		}
	}

	/// Запросить письмо для восстановления доступа к аккаунту Firebase.
	static func resetPassword(email:String, completion: @escaping Completion.Error) {
		Auth.auth().sendPasswordReset(withEmail: email) { error in
			completion(error)
		}
	}

	/// Совершить регистрацию по электронной почте.
	///
	/// - important: При успешной регистрации или если пользователь уже существует
	/// вход происходит автоматически.
	///
	/// - Parameters:
	/// 	- email: Почта.
	/// 	- password: Пароль (текстом).
	/// 	- completion: Блок, вызываемый при окончании запроса.
	static func signUp(email:String,
					   password:String,
					   signInIfUserExists:Bool = true,
					   completion: @escaping Completion.Error) {
		Auth.auth().createUser(withEmail: email, password: password) { result, error in
			if error == nil,
				let firebaseUser = result?.user,
				result?.additionalUserInfo?.isNewUser == true {

				let userRef = ref(usersRef).document(firebaseUser.uid)
				userRef.setData([
					Constants.User.id:firebaseUser.uid as Any,
					Constants.User.email:firebaseUser.email as Any
					])
			}

			if let error = error as? AuthErrorCode, error == .emailAlreadyInUse {
				signIn(email: email, password: password, completion: { error in
					completion(error)
				})
			}
			else if let error = error {
				completion(error)
			}
			else {
				completion(nil) // ок
			}
		}
	}

	/// Совершить вход по электронной почте.
	///
	/// - Parameters:
	///	  - email: Почта.
	///	  - password: Пароль (текстом).
	///	  - completion: Блок, вызываемый при окончании запроса.
	static func signIn(email:String, password:String, completion: @escaping Completion.Error) {
		Auth.auth().signIn(withEmail: email, password: password) { user, error in
			if let error = error {
				completion(error)
			}
			else {
				completion(nil) // ок
			}
		}
	}

	/// Обновить токен пользователя в базе данных.
	/// - important: Вызывается в AuthController при входе в систему.
	public static func updateToken(userId:String) {
		InstanceID.instanceID().instanceID { result, error in
			guard let tokenString = result?.token else { return }

			ref(usersRef).document(userId).collection(Constants.User.tokens)
				.document(tokenString).setData([
					Constants.User.tokenDate:Date.nowTimestamp,
					Constants.User.tokenInfo:tokenString
					])
		}
	}

	/// Удалить токен пользователя в базе данных.
	/// - important: Вызывается в AuthController при выходе из систему.
	public static func removeToken(userId:String) {
		InstanceID.instanceID().instanceID { result, error in
			guard let tokenString = result?.token else { return }

			ref(usersRef).document(userId).collection(Constants.User.tokens)
				.document(tokenString).delete()
		}
	}

	/// Обновить местоположение пользователя в базе данных.
	/// - important: Периодически вызывается в AuthController.
	static func updateLocation(userId:String, _ location: CLLocation) {
		ref(usersRef).document(userId).updateData([
			Constants.User.locationDate:Date.nowTimestamp,
			Constants.User.latitude:location.coordinate.latitude,
			Constants.User.longitude:location.coordinate.longitude
			])
	}

	/// Удалить текущий токен пользователя из базы данных.
	/// - important: Вызывается в AuthController при выходе из системы.
	public static func updateLastSeen(userId:String) {
		ref(usersRef).document(userId).updateData([
			Constants.User.lastSeen:Date.nowTimestamp
			])
	}

	/// Обновить текущую версию приложения, которой пользуется пользователь.
	/// - important: Автоматически вызывается в AuthController.
	public static func updateVersionCode(userId:String) {
		ref(usersRef).document(userId).updateData([
			Constants.User.appVersion: Bundle.main.object(
				forInfoDictionaryKey: "CFBundleShortVersionString") as Any
			])
	}

	/// Совершить выход из аккаунта Firebase.
	/// - important: Вызывается в AuthController при выходе из системы.
	public static func signOut() {
		try? Auth.auth().signOut()
	}
}
