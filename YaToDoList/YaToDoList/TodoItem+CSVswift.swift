//
//  TodoItem+CSVswift.swift
//  YaToDoList
//
//  Created by Екатерина Вишневская on 16.06.2023.
//

import Foundation

extension TodoItem {
    static func parse(csv: String) -> TodoItem? {
        let a = csv.split(separator: ",", omittingEmptySubsequences: false).map { String($0)}
        guard a.count == 7 else {
            return nil
        }
        let id = a[0]
        let text = a[1]
        let importance: Importance?
        switch a[2] {
        case "":
            importance = .normal;
        case "важная":
            importance = .important;
        case "неважная":
            importance = .unimportant;
        default:
            importance = nil
        }
        guard let importance = importance else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let deadline = dateFormatter.date(from: a[3])
        let done: Bool
        switch a[4] {
        case "true": done = true;
        default:
            done = false
        }
        let creationDate = dateFormatter.date(from: a[5])
        guard let creationDate = creationDate else {
            return nil
        }
        let changeDate = dateFormatter.date(from: a[6])
        let item = TodoItem(id: id,text: text, importance: importance, deadline: deadline, done: done, creationDate: creationDate, changeDate: changeDate)
        return item
    }
    var csv: String {
        var s = id+","+text+","
        switch importance {
        case .unimportant:
            s+="неважная"+",";
        case .important:
            s+="важная"+",";
        case .normal:
            s+=",";
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        if let deadline = deadline {
            s+=dateFormatter.string(from: deadline) + ","
        } else {
            s+=","
        }
        s += done ? "true," : "false,"
        s+=dateFormatter.string(from: creationDate)+","
        if let changeDate = changeDate {
            s+=dateFormatter.string(from: changeDate)
        }
        return s
    }
}
