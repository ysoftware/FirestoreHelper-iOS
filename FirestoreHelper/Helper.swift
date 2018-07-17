//
//  Helper.swift
//  FirestoreHelper
//
//  Created by Yaroslav Erohin on 05.03.2018.
//  Copyright © 2018 Ysoftware. All rights reserved.
//

import FirebaseFirestore

extension FirestoreHelper {

	// MARK: - Paginated Lists

	public static func getList
		<T:Codable>(from query:Query,
					cursor:DocumentSnapshot?,
					limit:UInt,
					setup:Request? = nil,
					_ completion: @escaping (PaginatedResult<[T]>) -> Void) {
		var query = query.limit(to: Int(limit))
		if let setup = setup { query = setup.setupRequest(query) }
		if let cursor = cursor { query = query.start(afterDocument: cursor) }
		query.getDocuments { snapshot, error in
			if let error = error {
				return completion(.error(error))
			}
			guard let items = snapshot?.getArray(of: T.self) else {
				return completion(.error(FirestoreHelperError.parsingError))
			}
			completion(.data(items:items, cursor:snapshot?.documents.last))
		}
	}

	// MARK: - Lists

	public static func getList<T:Codable>(from query:Query,
										  _ completion: @escaping (Result<[T]>) -> Void) {
		query.getDocuments { snapshot, error in
			if let error = error {
				return completion(.error(error))
			}
			guard let items = snapshot?.getArray(of: T.self) else {
				return completion(.error(FirestoreHelperError.parsingError))
			}
			completion(.data(items))
		}
	}

	// MARK: - Objects

	public static func observe<T:Codable>(at document: DocumentReference,
										  _ block: @escaping (Result<T>) -> Void) -> ListenerRegistration {
		return document.addSnapshotListener { snapshot, error in
			if let error = error {
				return block(.error(error))
			}
			guard let item = snapshot?.getValue(T.self) else {
				return block(.error(FirestoreHelperError.parsingError))
			}
			block(.data(item))
		}
	}

	public static func get<T:Codable>(from document: DocumentReference,
									  _ completion: @escaping (Result<T>) -> Void) {
		document.getDocument { snapshot, error in
			if let error = error {
				return completion(.error(error))
			}
			guard let item = snapshot?.getValue(T.self) else {
				return completion(.error(FirestoreHelperError.parsingError))
			}
			completion(.data(item))
		}
	}

	public static func get<T:Codable>(from collection:CollectionReference,
									  with id:String,
									  _ completion: @escaping (Result<T>) -> Void) {
		guard id.count > 0 else { // protection from crash
			return completion(.error(FirestoreHelperError.invalidRequest))
		}
		get(from: collection.document(id), completion)
	}
}
