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
					setup:QuerySetupBlock? = nil,
					_ completion: @escaping ([T], DocumentSnapshot?, Error?) -> Void) {
		var query = query.limit(to: Int(limit))
		if let setup = setup { query = setup(query) }
		if let cursor = cursor { query = query.start(afterDocument: cursor) }
		query.getDocuments { snapshot, error in
			completion(snapshot?.getArray(of: T.self) ?? [], snapshot?.documents.last, error)
		}
	}

	// MARK: - Lists

	public static func getList<T:Codable>(from query:Query,
										  _ completion: @escaping ([T], Error?) -> Void) {
		query.getDocuments { snapshot, error in
			completion(snapshot?.getArray(of: T.self) ?? [], error)
		}
	}

	// MARK: - Objects

	public static func observe<T:Codable>(at document: DocumentReference,
										  _ block: @escaping (T?) -> Void) -> ListenerRegistration {
		return document.addSnapshotListener { snapshot, _ in
			block(snapshot?.getValue(T.self))
		}
	}

	public static func get<T:Codable>(from document: DocumentReference,
									  _ completion: @escaping (T?, Error?) -> Void) {
		document.getDocument { snapshot, error in
			completion(snapshot?.getValue(T.self), error)
		}
	}

	public static func get<T:Codable>(from collection:CollectionReference,
									  with id:String,
									  _ completion: @escaping (T?, Error?) -> Void) {
		guard id.count > 0 else { return completion(nil, nil) } // protection from crash
		get(from: collection.document(id), completion)
	}
}
