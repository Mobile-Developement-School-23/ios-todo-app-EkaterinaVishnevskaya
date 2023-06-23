//
//  TodoItem.swift
//  YaToDoList
//
//  Created by Екатерина Вишневская on 15.06.2023.
//

import Foundation

enum Importance: String {
    case unimportant = "неважная"
    case normal = "обычная"
    case important = "важная"
}

struct TodoItem {
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let done: Bool
    let creationDate: Date
    let changeDate: Date?
    
    init(id: String = UUID().uuidString, text: String, importance: Importance, deadline: Date? = nil, done: Bool, creationDate: Date = Date(), changeDate: Date? = nil) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.done = done
        self.creationDate = creationDate
        self.changeDate = changeDate
    }
}








