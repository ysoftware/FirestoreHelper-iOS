//
//  Request.swift
//  FirestoreHelper
//
//  Created by ysoftware on 17.07.2018.
//  Copyright © 2018 Ysoftware. All rights reserved.
//

import FirebaseFirestore

public protocol Request {

	func setupRequest(_ request:Query)->Query
}
