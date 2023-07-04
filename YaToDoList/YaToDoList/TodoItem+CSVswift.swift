//
//  TodoItem+CSV.swift
//  YaToDoList
//
//  Created by Екатерина Вишневская on 16.06.2023.
//

import Foundation

extension TodoItem {
    static func parse(csv: String) -> TodoItem? {
        let split = csv.split(separator: ";", omittingEmptySubsequences: false).map { String($0)}
        guard split.count == 7 else {
            return nil
        }
        let id = split[0]
        let text = split[1]
        let importance: Importance?
        switch split[2] {
        case "":
            importance = .normal
        case "важная":
            importance = .important
        case "неважная":
            importance = .unimportant
        default:
            importance = nil
        }
        guard let importance = importance else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let deadline = dateFormatter.date(from: split[3])
        let done: Bool
        switch split[4] {
        case "true":
            done = true
        default:
            done = false
        }
        let creationDate = dateFormatter.date(from: split[5])
        guard let creationDate = creationDate else {
            return nil
        }
        let changeDate = dateFormatter.date(from: split[6])
        let item = TodoItem(id: id,
                            text: text,
                            importance: importance,
                            deadline: deadline,
                            done: done,
                            creationDate: creationDate,
                            changeDate: changeDate)
        return item
    }
    var csv: String {
        var str = id+","+text+";"
        switch importance {
        case .unimportant:
            str+="неважная"+";"
        case .important:
            str+="важная"+";"
        case .normal:
            str+=","
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        if let deadline = deadline {
            str+=dateFormatter.string(from: deadline) + ";"
        } else {
            str+=";"
        }
        str += done ? "true," : "false,"
        str+=dateFormatter.string(from: creationDate)+";"
        if let changeDate = changeDate {
            str+=dateFormatter.string(from: changeDate)
        }
        return str
    }
}
