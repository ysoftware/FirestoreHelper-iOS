//
//  Codable.swift
//  FirestoreHelper
//
//  Created by Yaroslav Erohin on01.10.2017.
//  Copyright © 2017 Ysoftware. All rights reserved.
//

import Foundation
import FirebaseFirestore

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

/// GeoPoint
protocol CodableGeoPoint: Codable {
	var latitude: Double { get }
	var longitude: Double { get }

	init(latitude: Double, longitude: Double)
}

enum CodableGeoPointCodingKeys: CodingKey {
	case latitude, longitude
}

extension CodableGeoPoint {
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodableGeoPointCodingKeys.self)
		let latitude = try container.decode(Double.self, forKey: .latitude)
		let longitude = try container.decode(Double.self, forKey: .longitude)

		self.init(latitude: latitude, longitude: longitude)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodableGeoPointCodingKeys.self)
		try container.encode(latitude, forKey: .latitude)
		try container.encode(longitude, forKey: .longitude)
	}
}

extension GeoPoint: CodableGeoPoint {}
