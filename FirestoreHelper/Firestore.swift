//
//  Firestore.swift
//  FirestoreHelper
//
//  Created by Yaroslav Erohin on 04.10.2017.
//  Copyright © 2017 Ysoftware. All rights reserved.
//

import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

///	Набор статических методов для работы с базой данных Firebase Firestore.
/// Добавление методов, необходимых этому приложению рекомендуется путём расширения этого объекта.
public struct FirestoreHelper {
	private init() {}

    // MARK: - Methods

	/// Возвращает текущего пользователя Firebase.
    public static var currentUser:FirebaseAuth.User? { return Auth.auth().currentUser }

	/// Возвращает ссылку на коллекцию в базе данных Firebase Firestore.
	///
	/// Например,
	///
	/// `ref(.users, [userId, "email"])`
	///
	/// вернёт ссылку на email пользователя.
	///
	/// - Parameters:
	/// 	- from: Тип ветви, например .user.
	/// 	- children: Список названий дочерних ветвей.
	/// - returns: Cсылку на ветвь в базе данных Firebase.
    public static func ref(_ collection:String) -> CollectionReference {
        return Firestore.firestore().collection(collection)
    }
	
	public static func move(document:DocumentReference,
							to newDocument: DocumentReference,
							_ completion: ((Error?) -> Void)? = nil) {
		copy(document: document, to: newDocument) { error in
			if error == nil {
				document.delete(completion: completion)
			}
		}
	}

	public static func copy(document:DocumentReference,
							to newDocument: DocumentReference,
							_ completion: ((Error?) -> Void)? = nil) {
		document.getDocument { snapshot, error in
			guard error == nil, let data = snapshot?.data() else { return }
			newDocument.setData(data, completion: completion)
		}
	}
}
