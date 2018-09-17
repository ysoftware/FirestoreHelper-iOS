//
//  Likeable.swift
//  FirestoreHelper
//
//  Created by ysoftware on 17.09.2018.
//  Copyright © 2018 Ysoftware. All rights reserved.
//

import Foundation

protocol Likeable: class {

	var likes:[String:Bool]? { get set }

	var likesCount:Int? { get set }

	func setLiking(_ liking:Bool, userId:String)
}

extension Likeable {

	func setLiking(_ liking:Bool, userId:String) {
		if likes == nil {
			likes = [:]
		}
		likes![userId] = liking ? true : nil
	}
}
