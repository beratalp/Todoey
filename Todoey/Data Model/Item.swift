//
//  Item.swift
//  Todoey
//
//  Created by Alp Erbil on 6.09.2019.
//  Copyright © 2019 Alp Erbil. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var isDone: Bool = false
    @objc dynamic var dateCreated: Date?
    var parent = LinkingObjects(fromType: Category.self, property: "items")
}
