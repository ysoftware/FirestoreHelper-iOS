//
//  Extensions.swift
//  FirestoreHelper
//
//  Created by Yaroslav Erohin on 05.01.2018.
//  Copyright © 2018 Ysoftware. All rights reserved.
//

import UIKit

extension String {

	func advancingLastLetter() -> String {
		guard count > 0 else { return self }

		let lastLetterIndex = index(endIndex, offsetBy: -1)
		let start = String(self[..<lastLetterIndex])
		let end = String(self[lastLetterIndex...])
		return start + (end.nextLetter() ?? end)
	}

	func nextLetter() -> String? {
		guard let uniCode = UnicodeScalar(self) else {
			return nil
		}

		switch uniCode {
		case "A" ..< "Z", "a" ..< "z":
			return String(UnicodeScalar(uniCode.value + 1)!)
		default:
			return nil
		}
	}
}

extension Date {

	struct Formatter {
		static let iso8601: DateFormatter = {
			let formatter = DateFormatter()
			formatter.calendar = Calendar(identifier: .iso8601)
			formatter.locale = Locale(identifier: "ru_RU")
			formatter.timeZone = TimeZone(abbreviation: "GMT")
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
			return formatter
		}()
	}

	static func from(iso8601 string:String?) -> Date? {
		if let string_ = string {
			return Formatter.iso8601.date(from: string_)
		}
		return nil
	}

	var iso8601: String {
		return Formatter.iso8601.string(from: self)
	}

	/// returns current date as string in iso8601 format
	static var nowTimestamp: String {
		return Formatter.iso8601.string(from: Date())
	}

	static var nowIso8601:String {
		return Date().iso8601
	}
}

extension UIViewController {

	func call(title:String = "Внимание!",
			  message:String? = nil,
			  buttonTitle:String = "ОК",
			  completion: (()->Void)? = nil) {
		guard message != nil else { return }

		let string = message
		let alert = UIAlertController(title: title, message: string, preferredStyle: .alert)
		let action = UIAlertAction(title: buttonTitle, style: .default) { _ in
			completion?()
			alert.dismiss(animated: true)
		}
		alert.addAction(action)
		present(alert, animated: true, completion: nil)
	}
}
