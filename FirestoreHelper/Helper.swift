//
//  Helper.swift
//  FirestoreHelper
//
//  Created by Yaroslav Erohin on 05.03.2018.
//  Copyright © 2018 Ysoftware. All rights reserved.
//

import FirebaseFirestore
import Result

extension FirestoreHelper {

	// MARK: - Paginated Lists

	public static func getList
		<T:Codable>(from query:Query,
					cursor:DocumentSnapshot?,
					limit:UInt,
					setup:Request? = nil,
					_ completion: @escaping (Result<PaginatedResponse<[T]>, FirestoreHelperError>) -> Void) {
		var query = query.limit(to: Int(limit))
		if let setup = setup { query = setup.setupRequest(query) }
		if let cursor = cursor { query = query.start(afterDocument: cursor) }
		query.getDocuments { snapshot, error in
			if let error = error {
				return completion(.failure(FirestoreHelperError.other(error)))
			}
			guard let items = snapshot?.getArray(of: T.self) else {
				return completion(.failure(FirestoreHelperError.parsingError))
			}
			completion(.success(PaginatedResponse(items:items, cursor:snapshot?.documents.last)))
		}
	}

	// MARK: - Lists

	public static func getList<T:Codable>(from query:Query,
										  _ completion: @escaping (Result<[T], FirestoreHelperError>) -> Void) {
		query.getDocuments { snapshot, error in
			if let error = error {
				return completion(.failure(FirestoreHelperError.other(error)))
			}
			guard let items = snapshot?.getArray(of: T.self) else {
				return completion(.failure(FirestoreHelperError.parsingError))
			}
			completion(.success(items))
		}
	}

	// MARK: - Objects

	public static func observe<T:Codable>(at document: DocumentReference,
										  _ block: @escaping (Result<T, FirestoreHelperError>) -> Void) -> ListenerRegistration {
		return document.addSnapshotListener { snapshot, error in
			if let error = error {
				return block(.failure(FirestoreHelperError.other(error)))
			}
			guard let item = snapshot?.getValue(T.self) else {
				return block(.failure(FirestoreHelperError.parsingError))
			}
			block(.success(item))
		}
	}

	public static func get<T:Codable>(from document: DocumentReference,
									  _ completion: @escaping (Result<T, FirestoreHelperError>) -> Void) {
		document.getDocument { snapshot, error in
			if let error = error {
				return completion(.failure(FirestoreHelperError.other(error)))
			}
			guard let item = snapshot?.getValue(T.self) else {
				return completion(.failure(FirestoreHelperError.parsingError))
			}
			completion(.success(item))
		}
	}

	public static func get<T:Codable>(from collection:CollectionReference,
									  with id:String,
									  _ completion: @escaping (Result<T, FirestoreHelperError>) -> Void) {
		guard id.count > 0 else { // protection from crash
			return completion(.failure(FirestoreHelperError.invalidRequest))
		}
		get(from: collection.document(id), completion)
	}
}
