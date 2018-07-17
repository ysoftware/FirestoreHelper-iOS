//
//  PaginatedResult.swift
//  FirestoreHelper
//
//  Created by ysoftware on 17.07.2018.
//  Copyright © 2018 Ysoftware. All rights reserved.
//

import FirebaseFirestore

public enum PaginatedResult<T> {

	case data(items:T, cursor:DocumentSnapshot?)

	case error(Error)
}
