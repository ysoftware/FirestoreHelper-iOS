//
//  PaginatedResult.swift
//  FirestoreHelper
//
//  Created by ysoftware on 17.07.2018.
//  Copyright © 2018 Ysoftware. All rights reserved.
//

import FirebaseFirestore

public struct PaginatedResponse<T> {

	public init(_ data:T, _ cursor:DocumentSnapshot?) {
		self.data = data
		self.cursor = cursor
	}

	public var data:T

	public var cursor:DocumentSnapshot?
}
