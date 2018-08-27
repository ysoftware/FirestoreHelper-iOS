//
//  PaginatedResult.swift
//  FirestoreHelper
//
//  Created by ysoftware on 17.07.2018.
//  Copyright © 2018 Ysoftware. All rights reserved.
//

import FirebaseFirestore

public struct PaginatedResponse<T> {

	public let items:T

	public let cursor:DocumentSnapshot?
}
