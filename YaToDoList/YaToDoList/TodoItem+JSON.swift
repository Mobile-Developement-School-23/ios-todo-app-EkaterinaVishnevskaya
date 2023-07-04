//
//  TodoItem+JSON.swift
//  YaToDoList
//
//  Created by Екатерина Вишневская on 16.06.2023.
//

import Foundation

extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        if let json = json as? [String: Any] {
            guard let id = json["id"] as? String else {
                return nil
            }
            guard let text = json["text"] as? String else {
                return nil
            }
            var importance: Importance?
            if let importanceString = json["importance"] as? String {
                switch importanceString {
                case "важная": importance = .important
                case "неважная": importance = .unimportant
                default: importance = nil
                }
            } else {
                importance = .normal
            }
            guard let importance = importance else {
                return nil
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            var deadline: Date?
            if let deadlineString = json["deadline"] as? String {
                deadline = dateFormatter.date(from: deadlineString)
            }
            guard let done = json["done"] as? Bool else {
                return nil
            }
            guard let creationDateString = json["creationDate"] as? String else {
                return nil
            }
            guard let creationDate = dateFormatter.date(from: creationDateString) else {
                return nil
            }
            var changeDate: Date?
            if let changeDateString = json["changeDate"] as? String {
                changeDate = dateFormatter.date(from: changeDateString)
            }
            let item = TodoItem(id: id,
                                text: text,
                                importance: importance,
                                deadline: deadline,
                                done: done,
                                creationDate: creationDate,
                                changeDate: changeDate)
            return item
        } else {
            return nil
        }
    }
    var json: Any {
        var data = [String: Any]()
        data["id"] = id
        data["text"] = text
        if self.importance != .normal {
            data["importance"] = "\(importance.rawValue)"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        if let deadline = deadline {
            data["deadline"] = dateFormatter.string(from: deadline)
        }
        data["done"] = done
        data["creationDate"] = dateFormatter.string(from: creationDate)
        if let changeDate = changeDate {
            data["changeDate"] = dateFormatter.string(from: changeDate)
        }
        return data
    }
}
