//
//  Transaction.swift
//  FirestoreHelper
//
//  Created by Yaroslav Erohin on 05.03.2018.
//  Copyright © 2018 Ysoftware. All rights reserved.
//

import FirebaseFirestore

extension FirestoreHelper {

	/// Метод-зеркало стандартного метода транзакции Firestore.
	///
	/// - Parameters:
	/// 	- updateBlock: Блок, который будет вызван в контексте транзакции.
	/// 	- completion: Блок, выполняемый по окончанию с результатом или ошибкой транзакции.
	public static func transaction(_ updateBlock: @escaping (Transaction, NSErrorPointer)->Any?,
								   completion: @escaping (Any?, Error?) -> Void) {
		Firestore.firestore().runTransaction(updateBlock, completion: completion)
	}

	/// Начать транзакцию Firestore для изменения одного поля в одном документе.
	///
	/// Текущее значение поля передаётся аргументом в updateBlock.
	/// Он так же должен вернуть новое значение поля.
	///
	/// - important: транзакция завершится неудачей, если загружаемого документа не существует.
	///
	/// - important: updateBlock может быть вызван несколько раз.
	/// Избегайте в нём кода, который может привести к ошибкам по этой причине.
	///
	/// - Parameters:
	/// 	- documentRef: Ссылка на документ, который будет изменяться в этой транзакции.
	/// 	- field: Поле, которое требуется запросить для изменения.
	/// 	- updateBlock: Блок кода для изменения параметра.
	/// 	- completion: Блок, выполняющийся по окончанию транзакции.
	/// 	- cancelIfNil: В случае, когда updateBlock возвращает nil и cancelIfNil:
	/// 	true: транзакция будет отменена; false: поле будет удалено из документа.
	/// 	- oldValue: Текущее значение поля в базе данных.
	/// 	- error: Ошибка при выполнении транзакции.
	public static func transaction(get documentRef:DocumentReference,
								   field:String,
								   cancelIfNil: Bool = true,
								   updateBlock: @escaping (_ oldValue: Any?) -> Any?,
								   completion: ((_ error:Error?) -> Void)? = nil) {
		transaction({ transaction, errorPointer in
			let document: DocumentSnapshot
			do {
				try document = transaction.getDocument(documentRef)
			}
			catch let fetchError as NSError {
				errorPointer?.pointee = fetchError
				return nil
			}
			let data = document.data() ?? [:]
			let oldValue = data[field]
			if let newValue = updateBlock(oldValue) {
				transaction.updateData([field: newValue], forDocument: documentRef)
			}
			else if !cancelIfNil {
				transaction.setNilValueForKey(field)
			}
			else {
				errorPointer?.pointee = nilError
				return nil
			}
			return nil
		}) { _, error in
			completion?(error)
		}
	}

	/// Начать транзакцию Firestore для изменения нескольких полей в одном документе.
	///
	/// Текущее значение полей передаётся массивом в updateBlock.
	/// Он так же должен вернуть массив новых значение полей.
	/// Порядок в массивах должен быть сохранён.
	/// Значение поля может быть nil. В этом случае, поле не изменяется.
	///
	/// - important: транзакция завершится неудачей, если загружаемого документа не существует.
	///
	/// - important: updateBlock может быть вызван несколько раз.
	/// Избегайте в нём кода, который может привести к ошибкам по этой причине.
	///
	/// - Parameters:
	/// 	- documentRef: Ссылка на документ, который будет изменяться в этой транзакции.
	/// 	- fields: Поля, которые требуется запросить.
	/// 	- updateBlock: Блок кода для изменения параметра.
	/// 	- completion: Блок, выполняющийся по окончанию транзакции.
	/// 	- oldValues: Массив текущих значений полей в базе данных.
	/// 	- error: Ошибка при выполнении транзакции.
	public static func transaction(get documentRef:DocumentReference,
								   fields:[String],
								   updateBlock: @escaping (_ oldValues: [Any?]) -> [Any?],
								   completion: ((_ error:Error?) -> Void)? = nil) {
		transaction({ transaction, errorPointer in
			let document: DocumentSnapshot
			do {
				try document = transaction.getDocument(documentRef)
			}
			catch let fetchError as NSError {
				errorPointer?.pointee = fetchError
				return nil
			}
			var oldValues:[Any?] = []
			for field in fields {
				let data = document.data() ?? [:]
				oldValues.append(data[field])
			}
			let newValues = updateBlock(oldValues)
			guard oldValues.count == newValues.count else {
				errorPointer?.pointee = sizeError
				return nil
			}
			var data:[String:Any] = [:]
			for i in 0 ..< fields.count {
				data[fields[i]] = newValues[i]
			}
			transaction.updateData(data, forDocument: documentRef)
			return nil
		}) { _, error in
			completion?(error)
		}
	}

	/// Начать транзакцию Firestore для изменения нескольких полей в нескольких документах.
	///
	/// Транзакция не завершится, если документов не существует.
	/// Текущее значение полей передаётся массивом в updateBlock.
	/// Он так же должен вернуть массив новых значение полей.
	/// Порядок в массивах должен быть сохранён.
	/// Значение поля может быть nil. В этом случае, поле не изменяется.
	///
	/// - important: updateBlock может быть вызван несколько раз.
	/// Избегайте в нём кода, который может привести к ошибкам по этой причине.
	///
	/// - Parameters:
	/// 	- documentRefs: Ссылки на документы, которые будут изменяться в этой транзакции.
	/// 	- fields: Поля, которые требуется запросить.
	/// 	- updateBlock: Блок кода для изменения параметра.
	/// 	- completion: Блок, выполняющийся по окончанию транзакции.
	/// 	- oldValues: Массив текущих значений полей в базе данных.
	/// 	- error: Ошибка при выполнении транзакции.
	public static func transaction(get documentRefs:[DocumentReference],
								   fields:[[String]],
								   updateBlock: @escaping (_ oldValues: [[Any?]]) -> [[Any?]],
								   completion: ((_ error:Error?) -> Void)? = nil) {
		transaction({ transaction, errorPointer in
			var oldValues:[[Any?]] = []
			var documents:[DocumentSnapshot?] = []

			for i in 0 ..< documentRefs.count {
				oldValues.append([])

				let document = try? transaction.getDocument(documentRefs[i])
				documents.append(document)
				let data = document?.data() ?? [:]
				for field in fields[i] {
					oldValues[i].append(data[field])
				}
			}
			let newValues = updateBlock(oldValues)
			guard oldValues.count == newValues.count else {
				errorPointer?.pointee = sizeError
				return nil
			}
			for i in 0 ..< newValues.count {
				if newValues[i].count != oldValues[i].count {
					errorPointer?.pointee = sizeError
					return nil
				}
			}
			var data:[[String:Any]] = []
			for i in 0 ..< documentRefs.count {
				data.append([:])
				for ii in 0 ..< fields[i].count {
					data[i][fields[i][ii]] = newValues[i][ii]
				}
				if let document = documents[i], document.exists {
					transaction.updateData(data[i], forDocument: documentRefs[i])
				}
				else {
					transaction.setData(data[i], forDocument: documentRefs[i])
				}
			}
			return nil
		}) { _, error in
			completion?(error)
		}
	}

	// MARK: - Transaction Errors

	fileprivate static let nilError = NSError(
		domain: "AppErrorDomain",
		code: -1,
		userInfo: [NSLocalizedDescriptionKey:
			"Transaction cancelled by getting nil as new data."])

	fileprivate static let sizeError = NSError(
		domain: "AppErrorDomain",
		code: -1,
		userInfo: [NSLocalizedDescriptionKey:
			"Transaction cancelled because newValues and oldValues arrays have different sizes."])

}
