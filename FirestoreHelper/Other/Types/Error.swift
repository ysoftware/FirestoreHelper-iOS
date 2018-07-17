//
//  Error.swift
//  ElasticSearch
//
//  Created by ysoftware on 17.07.2018.
//  Copyright © 2018 Ysoftware. All rights reserved.
//

import Foundation

public enum FirestoreHelperError: LocalizedError {

	case parsingError
	case invalidRequest

	public var errorDescription: String? {
		switch self {
		case .parsingError: return "Parsing error"
		case .invalidRequest: return "Invalid request"
		}
	}
}
