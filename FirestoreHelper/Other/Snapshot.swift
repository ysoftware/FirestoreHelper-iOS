//
//  Snapshot.swift
//  FirestoreHelper
//
//  Created by ysoftware on 16.07.2018.
//  Copyright © 2018 Ysoftware. All rights reserved.
//

import FirebaseFirestore

// MARK: - Firestore

public extension DocumentSnapshot {

	/// Преобразовать снапшот документа Firestore в объект Swift.
	///
	/// Например,
	///
	/// ```
	/// .observeSingleEvent(of: .value, with: { snapshot in
	///   let user = snaphot.getValue(User.self)
	/// })
	/// ```
	///
	/// - Parameters:
	/// 	- class: Тип желаемого объекта.
	/// - returns: Объект или nil при ошибке (печатается в лог).
	func getValue<T: Codable>(_ class: T.Type = T.self) -> T? {
		guard let data = self.data() else { return nil }
		do {
			let data = try JSONSerialization.data(withJSONObject: data)
			return try JSONDecoder().decode(T.self, from: data)
		}
		catch {
			print("firestore snapshot.getValue (\(T.self)): \(error)")
			return nil
		}
	}
}

public extension QuerySnapshot {

	/// Запросить список объектов Codable из Firestore.
	func getArray<T: Codable>(of class: T.Type = T.self) -> [T] {
		var array:[T] = []
		for document in documents {
			do {
				let data = try JSONSerialization.data(withJSONObject: document.data(),
													  options: .prettyPrinted)
				array.append(try JSONDecoder().decode(T.self, from: data))
			}
			catch {
				print("firestore snapshot.getArray: \(error)")
			}
		}
		return array
	}
}

public extension DocumentReference {

	/// Записать данные в документ базы данных по данному указателю.
	///
	/// Например,
	///
	/// ```
	/// reference.set(object: user)
	/// ```
	///
	/// - Parameters:
	/// 	- object: Объект модели.
	public func set<T:Codable>(object:T, completion:Completion.Error? = nil) {
		do {
			let data = try JSONEncoder().encode(object)
			let value = try JSONDecoder().decode(JSONAny.self, from: data)
			setData(value.toDictionary(), completion: { error in
				completion?(error)
			})
		}
		catch let error {
			print("firestore reference.set: \(error)")
		}
	}

	/// Обновить данные в документ базы данных по данному указателю.
	///
	/// Например,
	///
	/// ```
	/// reference.set(object: user)
	/// ```

	/// - Parameters:
	/// 	- object: Объект модели.
	public func update<T:Codable>(with object:T, completion:Completion.Error? = nil) {
		do {
			let data = try JSONEncoder().encode(object)
			let value = try JSONDecoder().decode(JSONAny.self, from: data)
			updateData(value.toDictionary(), completion: { error in
				completion?(error)
			})
		}
		catch let error {
			print("firestore reference.set: \(error)")
		}
	}
}
