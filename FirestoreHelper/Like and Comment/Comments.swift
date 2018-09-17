//
//  Comments.swift
//  FirestoreHelper
//
//  Created by ysoftware on 17.09.2018.
//  Copyright © 2018 Ysoftware. All rights reserved.
//

import FirebaseFirestore

extension FirestoreHelper {

	// приставка fsh для избежания коллизии с другими полями документа
	private static let COMMENTS	 		= "fsh_comments"		// collection of comments
	private static let LIKES	 		= "fsh_likes"			// ids of users who liked ["id":true]
	private static let LIKESCOUNT 		= "fsh_likesCount"		// all likes
	private static let COMMENTSCOUNT	= "fsh_commentsCount"	// all comments/ratings
	private static let AVERAGERATING	= "fsh_averageRating"	// average of all ratings
	private static let RATINGSCOUNT		= "fsh_ratingsCount" 	// all ratings only

	/// Поставить или убрать лайк на указанный документ.
	///
	/// - Parameters:
	///   - liking: Значение лайка.
	///   - document: Ссылка на документ Firestore.
	public static func setLiking(_ liking:Bool,
								 userId:String,
								 document documentRef:DocumentReference) {
		transaction(get: documentRef,
					fields: [LIKESCOUNT, LIKES], updateBlock: { oldValues in
						var likes = oldValues[1] as? [String:Bool] ?? [:]
						guard (likes[userId] != nil) != liking else { return [nil, nil] }
						likes[userId] = liking ? true : nil
						return [likes.keys.count, likes]
		})
	}

	/// Добавить комментарий на указанный документ.
	///
	/// - Parameters:
	///   - comment: Новый комментарий.
	///   - path: Коллекция, к которой относится документ.
	///   - id: Идентификатор документа.
	///   - allowsMultipleComments: Разрешить ли пользователю оставлять комментарий несколько раз. Полезно, если комментарий используется для оценки товара.
	///   - completion: Блок вызываемый по окончанию операции. Содержит в себе ошибку, если операция не удалась.
	@discardableResult
	public static func addComment(_ comment:Comment,
								  userId:String,
								  for documentRef:DocumentReference,
								  allowsMultipleComments:Bool = true,
								  completion:Completion.Error?) -> String? {
		var commentRef = documentRef
		if allowsMultipleComments {
			commentRef = documentRef.collection(COMMENTS).document()
		}
		else {
			commentRef = documentRef.collection(COMMENTS).document(userId)
		}

		// advance comments count, ratings count and calculate new average rating
		transaction(get: [documentRef, commentRef],
					fields: [[COMMENTSCOUNT, RATINGSCOUNT, AVERAGERATING], ["id"]],
					updateBlock: { oldValues in
						let commentsCount = oldValues[0][0] as? Int ?? 0
						let ratingsCount  = oldValues[0][1] as? Int ?? 0
						let averateRating =	oldValues[0][2] as? Double ?? 0.0
						let commentExists = oldValues[1][0] != nil

						let commentsCountNew = commentsCount +
							((allowsMultipleComments || !commentExists) ? 1 : 0)

						var ratingsCountNew = ratingsCount
						var averageNew = averateRating
						if let rating = comment.rating {
							ratingsCountNew +=
								((allowsMultipleComments || !commentExists) ? 1 : 0)
							if ratingsCount == 0 {
								averageNew = rating
							}
							else {
								averageNew = averateRating + (rating - averateRating)
									/ Double(ratingsCount)
							}
						}
						return [[commentsCountNew, ratingsCountNew, averageNew], [nil]]
		}) { error in
			if error == nil {
				comment.id = commentRef.documentID
				commentRef.set(object: comment, completion: completion)
			}
			else {
				completion?(error)
			}
		}
		return commentRef.documentID
	}
}
