//
//  Comment.swift
//  FirestoreHelper
//
//  Created by ysoftware on 17.09.2018.
//  Copyright © 2018 Ysoftware. All rights reserved.
//

import Foundation

/// Представляет из себя обычный комментарий, оценку или рейтинг.
public class Comment: Codable, Likeable {

	public var id:String = ""

	public var time:String = ""

	public var authorId:String = ""

	public var authorName:String? // для отображения имени пользователя в списке

	public var text:String? // оценка может быть без текста

	public var rating:Double?

	public var likes:[String:Bool]?

	public var likesCount:Int?
}

extension Comment: Equatable {

	public static func ==(lhs: Comment, rhs: Comment) -> Bool {
		return lhs.id == rhs.id
	}
}

extension Comment: CustomDebugStringConvertible {

	public var debugDescription: String {
		return "Comment: '\(id)', name: \(String(describing: text)), rating:\(String(describing: rating))"
	}
}
