//
//  Codable.swift
//  FirestoreHelper
//
//  Created by Yaroslav Erohin on01.10.2017.
//  Copyright © 2017 Ysoftware. All rights reserved.
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
}

// MARK: - Codable

/// T.init(Dictionary)
public extension Decodable {

	/// Инициализовать объект Decodable с помощью Dictionary.
	public init?(_ dict:Any?) {
		guard let dict = dict else { return nil }

		do {
			let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
			self = try JSONDecoder().decode(Self.self, from: data)
		}
		catch {
			print("decodable init: \(error)")
			return nil
		}
	}
}

/// T -> Dictionary
public extension Encodable {

	/// Преобразовать объект Encodable в Dictionary.
	public func toDictionary() -> [String:Any] {
		do {
			let data = try JSONEncoder().encode(self)
			let value = try JSONDecoder().decode(JSONAny.self, from: data)
			if let value_ = value.value as? [String:Any] {
				return value_
			}
			else {
				print("encodable.asDict: something went wrong and needs debugging")
				return [:]
			}
		}
		catch let error {
			print("encodable.asDict: \(error)")
			return [:]
		}
	}
}

/// Dictionary -> T
extension Dictionary where Key == String {

	/// Преобразовать в объект.
	/// - Parameter class: класс объекта.
	func parse<T:Decodable>(object class:T.Type = T.self) -> T? {
		do {
			let data = try JSONSerialization.data(withJSONObject: self)
			return try JSONDecoder().decode(T.self, from: data)
		}
		catch {
			print("search: parse \(T.self): \(error)")
			return nil
		}
	}
}

/// [Dictionary] -> [T:Decodable]
extension Array where Element == Dictionary<String, Any> {

	/// Преобразовать в объект.
	/// - Parameter class: класс объекта.
	func parse<T:Decodable>(arrayOf class:T.Type = T.self) -> [T] {
		do {
			let data = try JSONSerialization.data(withJSONObject: self)
			return try JSONDecoder().decode([T].self, from: data)
		}
		catch {
			print("search: parse arrayOf \(T.self): \(error)")
			return []
		}
	}

}

