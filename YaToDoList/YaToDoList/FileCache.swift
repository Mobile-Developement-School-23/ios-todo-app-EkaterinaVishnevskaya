//
//  FileCache.swift
//  YaToDoList
//
//  Created by Екатерина Вишневская on 16.06.2023.
//

import Foundation
import TodoItem

class FileCache {
    private(set) var todoList: [String: TodoItem] = [:]
    func delete(id: String) {
        todoList[id] = nil
    }
    func add(item: TodoItem) {
        todoList[item.id] = item
    }
    func saveAsJSON(filename: String) {
        do {
            let filePath = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first!.appendingPathComponent(filename)
            var arr = [[String: Any]]()
            for item in todoList.values {
                if let json = item.json as? [String: Any] {
                    arr.append(json)
                }
            }
            let jsonData = try JSONSerialization.data(withJSONObject: arr, options: [])
            try jsonData.write(to: filePath)
        } catch {
            print("Failed to save JSON: \(error.localizedDescription)")
        }
    }
    func loadFromJSON(filename: String) {
        do {
            let filePath = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first!.appendingPathComponent(filename)
            let jsonData = try Data(contentsOf: filePath)
            todoList.removeAll()
            if let loadedArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
                for json in loadedArray {
                    if let item = TodoItem.parse(json: json) {
                        todoList[item.id] = item
                    }
                }
            }
        } catch {
            print("Failed to load list from JSON: \(error.localizedDescription)")
        }
    }
    func saveAsCSV(filename: String) {
        do {
            let filePath = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first!.appendingPathComponent(filename)
            var data = String()
            data += "id,text,importance,deadline,done,creationDate,changeDate\n"
            for item in todoList.values {
                data += "\(item.csv)\n"
            }
            try data.write(to: filePath, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to save CSV: \(error.localizedDescription)")
        }
    }
    func loadFromCSV(filename: String) {
        do {
            let filePath = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first!.appendingPathComponent(filename)
            let csv = try String(contentsOf: filePath, encoding: .utf8)
            todoList.removeAll()
            let strings: [String] = csv.components(
                separatedBy: "\n"
            )
            for str in strings {
                if let item = TodoItem.parse(csv: str) {
                    todoList[item.id] = item
                }
            }
        } catch {
            print("Failed to load items: \(error.localizedDescription)")
        }
    }
}
