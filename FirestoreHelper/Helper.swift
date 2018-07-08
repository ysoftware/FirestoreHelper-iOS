//
//  Helper.swift
//  FirestoreHelper
//
//  Created by Yaroslav Erohin on 05.03.2018.
//  Copyright © 2018 Ysoftware. All rights reserved.
//

import FirebaseFirestore

extension Firestore {

	// MARK: - Paginated Lists

	public static func getList<T:Codable>(from query:Query,
										  cursor:DocumentSnapshot?,
										  limit:UInt,
										  setup:QuerySetupBlock? = nil,
										  _ completion: @escaping ([T], DocumentSnapshot?) -> Void) {
		var query = query.limit(to: Int(limit))
		if let setup = setup { query = setup(query) }
		if let cursor = cursor { query = query.start(afterDocument: cursor) }
		query.getDocuments { snapshot, _ in
			completion(snapshot?.getArray(of: T.self) ?? [], snapshot?.documents.last)
		}
	}

	public static func getList<T:Codable>(_ collection:Collection,
										  cursor:DocumentSnapshot?,
										  limit:UInt,
										  setup:QuerySetupBlock? = nil,
										  _ completion: @escaping ([T], DocumentSnapshot?) -> Void) {
		getList(from: ref(collection), cursor: cursor, limit: limit, setup: setup, completion)
	}

	// MARK: - Lists

	public static func getList<T:Codable>(from query:Query,
										  _ completion: @escaping ([T]) -> Void) {
		query.getDocuments { snapshot, _ in
			completion(snapshot?.getArray(of: T.self) ?? [])
		}
	}

	public static func getList<T:Codable>(_ collection:Collection,
										  _ completion: @escaping ([T]) -> Void) {
		getList(from: ref(collection), completion)
	}

	// MARK: - Objects

	public static func observe<T:Codable>(at document: DocumentReference,
										  _ block: @escaping (T?) -> Void) -> ListenerRegistration {
		return document.addSnapshotListener { snapshot, _ in
			block(snapshot?.getValue(T.self))
		}
	}

	public static func get<T:Codable>(from document: DocumentReference,
									  _ completion: @escaping (T?) -> Void) {
		document.getDocument { snapshot, _ in
			completion(snapshot?.getValue(T.self))
		}
	}

	public static func get<T:Codable>(from collection:CollectionReference,
									  with id:String,
									  _ completion: @escaping (T?) -> Void) {
		guard id.count > 0 else { return completion(nil) } // protection from crash
		get(from: collection.document(id), completion)
	}

	public static func get<T:Codable>(_ collection:Collection,
									  with id:String,
									  _ completion: @escaping (T?) -> Void) {
		get(from: ref(collection), with:id, completion)
	}

	// MARK: - Write

	public static func update(_ document:DocumentReference,
							  with object:Encodable) {
		document.updateData(object.toDictionary())
	}

	public static func update(in collection: CollectionReference,
							  id:String,
							  with object:Encodable) {
		update(collection.document(id), with: object)
	}

	public static func update(_ collection:Collection,
							  id:String,
							  with object:Encodable) {
		update(in: ref(collection), id: id, with: object)
	}

}
