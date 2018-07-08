//
//  Completion.swift
//  FirestoreHelper
//
//  Created by Yaroslav Erohin on 08.07.2018.
//  Copyright © 2018 Ysoftware. All rights reserved.
//

import UIKit

public struct Completion {
	
	public typealias String = (Swift.String?) -> Void
	public typealias Bool = (Swift.Bool) -> Void
	public typealias BoolOptional = (Swift.Bool?) -> Void
	public typealias Float = (Swift.Float?) -> Void
	public typealias Int = (Swift.Int?) -> Void
	public typealias Error = (Swift.Error?) -> Void
	public typealias Image = (UIImage?) -> Void
}
