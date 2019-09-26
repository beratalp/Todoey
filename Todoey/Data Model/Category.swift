//
//  Category.swift
//  Todoey
//
//  Created by Alp Erbil on 6.09.2019.
//  Copyright © 2019 Alp Erbil. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let items = List<Item>()
}
